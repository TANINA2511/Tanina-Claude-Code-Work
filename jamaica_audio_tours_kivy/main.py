import os
import math
import sqlite3
from kivy.lang import Builder
from kivymd.app import MDApp
from kivymd.uix.screen import MDScreen
from kivymd.uix.button import MDRaisedButton
from kivymd.uix.label import MDLabel
from kivy.clock import Clock
from kivy.utils import platform

# Native Android imports via Pyjnius
if platform == 'android':
    from jnius import autoclass
    from android.permissions import request_permissions, Permission

    # Android System Services
    PythonActivity = autoclass('org.kivy.android.PythonActivity')
    currentActivity = PythonActivity.mActivity
    Context = autoclass('android.content.Context')
    LocationManager = autoclass('android.location.LocationManager')
    MediaPlayer = autoclass('android.media.MediaPlayer')

    location_service = currentActivity.getSystemService(Context.LOCATION_SERVICE)
else:
    location_service = None
    MediaPlayer = None

# UI Layout using Kivy Design Language
KV = '''
MDScreen:
    md_bg_color: 0.1, 0.1, 0.1, 1

    MDBoxLayout:
        orientation: 'vertical'
        padding: 24
        spacing: 20

        MDLabel:
            text: "EcoEcos de Jamaica"
            font_style: "H4"
            theme_text_color: "Custom"
            text_color: 0.95, 0.75, 0.15, 1
            halign: "center"
            size_hint_y: None
            height: self.texture_size[1]

        MDLabel:
            id: status_label
            text: "Iniciando sistema de posicionamiento..."
            font_style: "Subtitle1"
            theme_text_color: "Custom"
            text_color: 0.9, 0.9, 0.9, 1
            halign: "center"

        MDCard:
            orientation: 'vertical'
            padding: 16
            size_hint: 1, 0.4
            md_bg_color: 0.15, 0.15, 0.15, 1
            radius: [12, ]

            MDLabel:
                id: site_title
                text: "Buscando Puntos de Interés..."
                font_style: "H5"
                theme_text_color: "Custom"
                text_color: 1, 1, 1, 1
                halign: "center"

            MDLabel:
                id: site_desc
                text: "Acerquese a un sitio histórico de Jamaica para iniciar la reproducción automática."
                font_style: "Body1"
                theme_text_color: "Custom"
                text_color: 0.7, 0.7, 0.7, 1
                halign: "center"

        MDRaisedButton:
            id: action_btn
            text: "SIMULAR LLEGADA A PORT ROYAL"
            pos_hint: {"center_x": .5}
            md_bg_color: 0.15, 0.65, 0.25, 1
            on_release: app.simulate_location_match()
'''


class EcoEcosApp(MDApp):
    def build(self):
        self.theme_cls.theme_style = "Dark"
        self.db_path = 'jamaica_heritage.db'
        self.current_playing_id = None
        self.player = None

        self.init_local_database()
        self.setup_audio_assets()

        if platform == 'android':
            request_permissions([Permission.ACCESS_FINE_LOCATION, Permission.ACCESS_COARSE_LOCATION])
            Clock.schedule_interval(self.check_android_gps, 4.0)  # Check hardware matrix every 4 seconds

        return Builder.load_string(KV)

    def init_local_database(self):
        """Creates a fully local database pre-populated with Jamaican heritage vector fields."""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS heritage_sites (
                id TEXT PRIMARY KEY,
                name TEXT,
                description TEXT,
                latitude REAL,
                longitude REAL,
                radius_meters REAL,
                audio_file TEXT
            )
        ''')

        # Seed core Jamaican sites
        sites = [
            ('poi_port_royal', 'Port Royal (Fuerte Charles)', 'Antigua sede de piratas. Capturado por los británicos en 1655.', 17.9372, -76.8407, 100.0, 'port_royal.mp3'),
            ('poi_blue_mtns', 'Parque Nacional Montañas Azules', 'Hogar de los Maroons y plantaciones de café patrimoniales.', 18.0460, -76.6990, 250.0, 'blue_mountains.mp3')
        ]
        cursor.executemany('INSERT OR REPLACE INTO heritage_sites VALUES (?,?,?,?,?,?,?)', sites)
        conn.commit()
        conn.close()

    def setup_audio_assets(self):
        """Ensures silence placeholders exist if local raw files aren't deployed yet."""
        # In production, these .mp3 binaries are pre-packaged into the assets root
        for f in ['port_royal.mp3', 'blue_mountains.mp3']:
            if not os.path.exists(f):
                with open(f, 'wb') as audio_stub:
                    audio_stub.write(b'\x00' * 1024)  # Create low-weight data placeholder

    def haversine_distance(self, lat1, lon1, lat2, lon2):
        """Evaluates ground distance in meters completely offline."""
        R = 6371000.0
        phi1 = math.radians(lat1)
        phi2 = math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)
        a = math.sin(delta_phi / 2)**2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2)**2
        return R * (2 * math.atan2(math.sqrt(a), math.sqrt(1 - a)))

    def check_android_gps(self, dt):
        if not location_service:
            return

        # Fetch device's hardware last known GPS fix coordinates
        location = location_service.getLastKnownLocation(LocationManager.GPS_PROVIDER)
        if location:
            lat = location.getLatitude()
            lon = location.getLongitude()
            self.root.ids.status_label.text = f"GPS Local Activo: {round(lat,4)}, {round(lon,4)}"
            self.evaluate_geofences(lat, lon)

    def evaluate_geofences(self, lat, lon):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, description, latitude, longitude, radius_meters, audio_file FROM heritage_sites")

        for row in cursor.fetchall():
            site_id, name, desc, site_lat, site_lon, radius, audio_file = row
            distance = self.haversine_distance(lat, lon, site_lat, site_lon)

            if distance <= radius:
                if self.current_playing_id != site_id:
                    self.current_playing_id = site_id
                    self.root.ids.site_title.text = name
                    self.root.ids.site_desc.text = desc
                    self.play_audio_native(audio_file)
                conn.close()
                return
        conn.close()

    def play_audio_native(self, filename):
        """Triggers local background audio using Android's native hardware engine."""
        if platform == 'android' and MediaPlayer:
            try:
                if self.player:
                    self.player.stop()
                    self.player.release()

                self.player = MediaPlayer()
                # Targets the application runtime base sandbox directory
                path = os.path.join(os.getcwd(), filename)
                self.player.setDataSource(path)
                self.player.prepare()
                self.player.start()
            except Exception as e:
                self.root.ids.status_label.text = f"Error de Audio: {str(e)}"

    def simulate_location_match(self):
        """Debug simulator path bypassing hardware for indoor environment validation."""
        # Simulating exact entry coordinates inside Fort Charles, Port Royal boundary
        self.root.ids.status_label.text = "Simulación Activada: Ubicado en Port Royal"
        self.evaluate_geofences(17.9372, -76.8407)


if __name__ == '__main__':
    EcoEcosApp().run()
