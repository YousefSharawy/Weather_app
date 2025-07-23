
class AstroModel {
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;

  const AstroModel({required this.sunrise, required this.sunset, required this.moonrise, required this.moonset});

  factory AstroModel.fromJson(Map<String, dynamic> json) => AstroModel(
    sunrise: json['sunrise'] as String,
    sunset: json['sunset'] as String,
    moonrise: json['moonrise'] as String,
    moonset: json['moonset'] as String,
  );
}
