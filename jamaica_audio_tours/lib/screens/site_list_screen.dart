import 'package:flutter/material.dart';

import '../models/heritage_site.dart';
import '../services/narration_player.dart';
import '../services/site_repository.dart';
import 'site_detail_screen.dart';
import 'tour_map_screen.dart';

/// Offline-friendly catalog of every site, for browsing without relying
/// on map tiles (which require a network connection to download).
class SiteListScreen extends StatefulWidget {
  const SiteListScreen({super.key});

  @override
  State<SiteListScreen> createState() => _SiteListScreenState();
}

class _SiteListScreenState extends State<SiteListScreen> {
  final _repository = SiteRepository();
  final _narrationPlayer = NarrationPlayer();
  List<HeritageSite> _sites = [];

  @override
  void initState() {
    super.initState();
    _repository.loadSites().then((sites) => setState(() => _sites = sites));
  }

  @override
  void dispose() {
    _narrationPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recorridos por Jamaica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Ver mapa',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TourMapScreen()),
            ),
          ),
        ],
      ),
      body: _sites.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _sites.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final site = _sites[index];
                return ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(site.name),
                  subtitle: Text(site.shortDescription),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SiteDetailScreen(
                        site: site,
                        narrationPlayer: _narrationPlayer,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
