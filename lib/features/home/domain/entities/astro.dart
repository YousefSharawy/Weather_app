class Astro {
   final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;

  const Astro({required this.sunrise, required this.sunset, required this.moonrise, required this.moonset});

  factory Astro.fromJson(Map<String, dynamic> json) => Astro(
    sunrise: json['sunrise'] as String,
    sunset: json['sunset'] as String,
    moonrise: json['moonrise'] as String,
    moonset: json['moonset'] as String,
  );
}
