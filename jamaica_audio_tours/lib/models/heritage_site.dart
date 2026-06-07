class HeritageSite {
  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final double triggerRadiusMeters;
  final String shortDescription;
  final String narrationEs;

  const HeritageSite({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.triggerRadiusMeters,
    required this.shortDescription,
    required this.narrationEs,
  });

  factory HeritageSite.fromJson(Map<String, dynamic> json) {
    return HeritageSite(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      triggerRadiusMeters: (json['triggerRadiusMeters'] as num).toDouble(),
      shortDescription: json['shortDescription'] as String,
      narrationEs: json['narrationEs'] as String,
    );
  }
}
