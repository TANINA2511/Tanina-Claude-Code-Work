import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/heritage_site.dart';
import '../services/geofence_service.dart';
import '../services/narration_player.dart';
import '../services/site_repository.dart';
import 'site_detail_screen.dart';

const _jamaicaCenter = LatLng(18.1096, -77.2975);

class TourMapScreen extends StatefulWidget {
  const TourMapScreen({super.key});

  @override
  State<TourMapScreen> createState() => _TourMapScreenState();
}

class _TourMapScreenState extends State<TourMapScreen> {
  final _repository = SiteRepository();
  final _narrationPlayer = NarrationPlayer();

  List<HeritageSite> _sites = [];
  GeofenceService? _geofenceService;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final sites = await _repository.loadSites();
    setState(() {
      _sites = sites;
      _loading = false;
    });

    _geofenceService = GeofenceService(
      sites: sites,
      onSiteEntered: _onSiteEntered,
    );
    await _geofenceService?.start();
  }

  void _onSiteEntered(HeritageSite site) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SiteDetailScreen(
          site: site,
          narrationPlayer: _narrationPlayer,
          autoPlay: true,
        ),
      ),
    );
  }

  void _openSite(HeritageSite site) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SiteDetailScreen(
          site: site,
          narrationPlayer: _narrationPlayer,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _geofenceService?.dispose();
    _narrationPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tours de Jamaica')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: _jamaicaCenter,
          initialZoom: 9,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.jamaica_audio_tours',
          ),
          MarkerLayer(
            markers: _sites
                .map(
                  (site) => Marker(
                    point: LatLng(site.latitude, site.longitude),
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => _openSite(site),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
