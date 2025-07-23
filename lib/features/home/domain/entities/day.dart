import 'package:weather_app/features/home/domain/entities/condition.dart';

class Day {
  final double maxtempC;
  final double maxtempF;
  final double mintempC;
  final double mintempF;

  final Condition condition;

  const Day({
    required this.condition,
    required this.maxtempC,
    required this.maxtempF,
    required this.mintempC,
    required this.mintempF,
  });
}