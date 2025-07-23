import 'package:weather_app/features/home/domain/entities/condition.dart';

class Current {
  final double tempC;
  final int isDay;
  final Condition condition;
  final double windKph;
  final int windDegree;
  final String windDir;
  final int humidity;
  final int cloud;

  const Current({
    required this.tempC,
    required this.isDay,
    required this.condition,
    required this.windKph,
    required this.windDegree,
    required this.windDir,
    required this.humidity,
    required this.cloud,
  });
}
