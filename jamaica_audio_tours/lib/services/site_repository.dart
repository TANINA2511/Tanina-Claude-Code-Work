import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/heritage_site.dart';

/// Loads heritage site data bundled with the app, so the tour catalog
/// works fully offline without any network call.
class SiteRepository {
  Future<List<HeritageSite>> loadSites() async {
    final raw = await rootBundle.loadString('assets/data/sites.json');
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => HeritageSite.fromJson(entry as Map<String, dynamic>))
        .toList();
  }
}
