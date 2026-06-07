import 'package:flutter/material.dart';

import '../models/heritage_site.dart';
import '../services/narration_player.dart';

class SiteDetailScreen extends StatefulWidget {
  final HeritageSite site;
  final NarrationPlayer narrationPlayer;
  final bool autoPlay;

  const SiteDetailScreen({
    super.key,
    required this.site,
    required this.narrationPlayer,
    this.autoPlay = false,
  });

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _play());
    }
  }

  Future<void> _play() async {
    setState(() => _isPlaying = true);
    await widget.narrationPlayer.speak(widget.site.narrationEs);
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _stop() async {
    await widget.narrationPlayer.stop();
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    widget.narrationPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    return Scaffold(
      appBar: AppBar(title: Text(site.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(label: Text(site.category)),
            const SizedBox(height: 12),
            Text(site.shortDescription, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  site.narrationEs,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isPlaying ? null : _play,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Reproducir narración'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _isPlaying ? _stop : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Detener'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
