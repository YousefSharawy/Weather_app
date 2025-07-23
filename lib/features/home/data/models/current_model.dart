import 'condition_model.dart';

class CurrentModel {
  final double tempC;
  final int isDay;
  final ConditionModel condition;
  final double windKph;
  final int windDegree;
  final String windDir;
  final int humidity;
  final int cloud;

  const CurrentModel({
    required this.tempC,
    required this.isDay,
    required this.condition,
    required this.windKph,
    required this.windDegree,
    required this.windDir,
    required this.humidity,
    required this.cloud,
  });

  factory CurrentModel.fromJson(Map<String, dynamic> json) => CurrentModel(
    tempC: (json['temp_c'] as num).toDouble(),
    isDay: json['is_day'] as int,
    condition: ConditionModel.fromJson(
      json['condition'] as Map<String, dynamic>,
    ),
    windKph: (json['wind_kph'] as num).toDouble(),
    windDegree: json['wind_degree'] as int,
    windDir: json['wind_dir'] as String,
    humidity: json['humidity'] as int,
    cloud: json['cloud'] as int,
  );
}
