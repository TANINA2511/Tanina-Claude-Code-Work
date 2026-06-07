# Tours de Jamaica (prototype)

A Flutter prototype for a mobile app that delivers GPS-triggered,
Spanish-language audio tours of Jamaica's heritage and natural sites —
designed to work offline, with no human guide required.

## How it works

- **Site catalog** (`assets/data/sites.json`): bundled with the app, so
  it loads with no network connection. Each entry has GPS coordinates, a
  trigger radius, and Spanish-language narration text.
- **Geofencing** (`lib/services/geofence_service.dart`): watches the
  device's GPS stream and fires when the user enters a site's radius —
  computed entirely on-device.
- **Narration** (`lib/services/narration_player.dart`): speaks the
  Spanish narration via on-device text-to-speech, so playback works
  offline. See `docs/audio_pipeline.md` for how to swap in
  professionally recorded audio.
- **Screens**: a browsable list of sites (works fully offline) and a map
  view (`lib/screens/tour_map_screen.dart`) for visual exploration.

## Running

```bash
flutter pub get
flutter run
```

Location permissions are declared for both Android
(`android/app/src/main/AndroidManifest.xml`) and iOS
(`ios/Runner/Info.plist`), including background location so tours can
trigger while the phone is locked or the app is backgrounded.

## Sample sites included

- Port Royal — sunken pirate city and 1692 earthquake history
- Blue and John Crow Mountains — UNESCO World Heritage site, Maroon history
- Rose Hall Great House — colonial-era plantation house and legends
- Dunn's River Falls — terraced waterfalls meeting the Caribbean Sea
- Seville Heritage Park — Taíno, Spanish, African and British history

## Next steps

- Replace TTS placeholder narration with professionally recorded
  Spanish audio (see `docs/audio_pipeline.md`)
- Add offline map tile caching for the visual map view
- Expand the site catalog with more locations and richer media
