import 'package:weather_app/features/home/data/models/condition_model.dart';

class HourModel {
  final String time;
  final double tempC;
  final ConditionModel condition;

  const HourModel({
    required this.condition,
    required this.time,
    required this.tempC,
  });

  factory HourModel.fromJson(Map<String, dynamic> json) => HourModel(
    time: json['time'] as String,
    tempC: (json['temp_c'] as num).toDouble(),

    condition: ConditionModel.fromJson(
      json['condition'] as Map<String, dynamic>,
    ),
  );
}
