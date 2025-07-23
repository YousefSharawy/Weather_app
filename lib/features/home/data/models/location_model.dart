
class LocationModel {
  final String name;
  final String? region;
  final String? country;
  final double? lat;
  final double? lon;
  final String? tzId;
  final int? localtimeEpoch;
  final String? localtime;

  const LocationModel({
    required this.name,
    this.region,
    this.country,
    this.lat,
    this.lon,
    this.tzId,
    this.localtimeEpoch,
    this.localtime,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    name: json['name'] as String,
    region: json['region'] as String?,
    country: json['country'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lon: (json['lon'] as num?)?.toDouble(),
    tzId: json['tz_id'] as String?,
    localtimeEpoch: json['localtime_epoch'] as int?,
    localtime: json['localtime'] as String?,
  );

  
}
