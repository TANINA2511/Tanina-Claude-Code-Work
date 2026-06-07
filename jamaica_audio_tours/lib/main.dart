import 'package:flutter/material.dart';

import 'screens/site_list_screen.dart';

void main() {
  runApp(const JamaicaAudioToursApp());
}

class JamaicaAudioToursApp extends StatelessWidget {
  const JamaicaAudioToursApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tours de Jamaica',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B7A43)),
        useMaterial3: true,
      ),
      home: const SiteListScreen(),
    );
  }
}
