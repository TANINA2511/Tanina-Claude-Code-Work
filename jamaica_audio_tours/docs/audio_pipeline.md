# Audio narration pipeline

## Current prototype

`NarrationPlayer` (`lib/services/narration_player.dart`) uses the
on-device `flutter_tts` engine to read the Spanish narration text stored
in `assets/data/sites.json`. This works fully offline once the user has
the Spanish (`es-ES`) voice pack installed on their device, and lets the
prototype demonstrate the full GPS-trigger → narration flow without
shipping large audio files.

## Moving to professionally recorded narration

To replace TTS with studio-recorded Spanish narration:

1. Record/produce one MP3 (or AAC) per site, named after the site `id`
   (e.g. `port_royal.mp3`), and add them under `assets/audio/`.
2. Add the files to `pubspec.yaml` under `flutter: assets:`.
3. Replace `NarrationPlayer` with an audio-file player (e.g. using
   `just_audio` or `audioplayers`) that resolves
   `assets/audio/<site.id>.mp3` and plays it. Because the files are
   bundled as Flutter assets, playback remains fully offline.
4. Optionally support downloadable "tour packs": fetch MP3s on Wi-Fi,
   cache them via `path_provider`, and fall back to TTS for any site
   whose recording hasn't been downloaded yet.

## Map tiles and offline use

`flutter_map` currently loads OpenStreetMap tiles over the network. The
GPS geofencing, site catalog, and narration playback all work without
connectivity — only the visual map requires data. For a fully offline
map experience, integrate an offline tile cache (e.g.
`flutter_map_tile_caching`) so users can pre-download the Jamaica region
on Wi-Fi before their trip.
