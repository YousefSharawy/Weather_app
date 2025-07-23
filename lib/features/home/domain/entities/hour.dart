import 'package:weather_app/features/home/domain/entities/condition.dart';

class Hour {
  final String time;
  final double tempC;
  final Condition condition;

  const Hour({
    required this.condition,
    required this.time,
    required this.tempC,
  });

  factory Hour.fromJson(Map<String, dynamic> json) => Hour(
    time: json['time'] as String,
    tempC: (json['temp_c'] as num).toDouble(),

    condition: Condition.fromJson(
      json['condition'] as Map<String, dynamic>,
    ),
  );
}