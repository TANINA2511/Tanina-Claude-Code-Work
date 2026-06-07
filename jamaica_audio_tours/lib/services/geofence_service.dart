import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/heritage_site.dart';

/// Watches the device's GPS position and fires a callback the first time
/// the user enters the trigger radius of each heritage site.
///
/// Distance checks run entirely on-device against the bundled site list,
/// so geofencing keeps working with no connectivity (only the underlying
/// GPS fix is required, which does not need a data connection).
class GeofenceService {
  final List<HeritageSite> sites;
  final void Function(HeritageSite site) onSiteEntered;

  StreamSubscription<Position>? _positionSubscription;
  final Set<String> _triggeredSiteIds = {};

  GeofenceService({required this.sites, required this.onSiteEntered});

  Future<void> start() async {
    final hasPermission = await _ensurePermission();
    if (!hasPermission) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: settings)
            .listen(_onPosition);
  }

  void _onPosition(Position position) {
    for (final site in sites) {
      if (_triggeredSiteIds.contains(site.id)) continue;

      final distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        site.latitude,
        site.longitude,
      );

      if (distanceMeters <= site.triggerRadiusMeters) {
        _triggeredSiteIds.add(site.id);
        onSiteEntered(site);
      }
    }
  }

  /// Allows a site to be re-triggered, e.g. if the user wants to replay
  /// a tour after leaving and re-entering the area.
  void resetTrigger(String siteId) => _triggeredSiteIds.remove(siteId);

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  void dispose() {
    _positionSubscription?.cancel();
  }
}
