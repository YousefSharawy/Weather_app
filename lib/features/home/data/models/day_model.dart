import 'package:weather_app/features/home/data/models/condition_model.dart';

class DayModel {
  final double maxtempC;
  final double maxtempF;
  final double mintempC;
  final double mintempF;

  final ConditionModel condition;

  const DayModel({
    required this.condition,
    required this.maxtempC,
    required this.maxtempF,
    required this.mintempC,
    required this.mintempF,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) => DayModel(
    condition: ConditionModel.fromJson(
      json['condition'] as Map<String, dynamic>,
    ),
    maxtempC: (json['maxtemp_c'] as num).toDouble(),
    maxtempF: (json['maxtemp_f'] as num).toDouble(),
    mintempC: (json['mintemp_c'] as num).toDouble(),
    mintempF: (json['mintemp_f'] as num).toDouble(),
  );
}
