
import 'astro_model.dart';
import 'day_model.dart';
import 'hour_model.dart';

class ForecastdayModel {
  final DayModel day;
  final AstroModel astro;
  final List<HourModel> hour;

   ForecastdayModel({
    required this.day,
    required this.astro,
    required this.hour,
  });

  factory ForecastdayModel.fromJson(Map<String, dynamic> json) => ForecastdayModel(
    day: DayModel.fromJson(json['day'] as Map<String, dynamic>),
    astro: AstroModel.fromJson(json['astro'] as Map<String, dynamic>),
    hour: (json['hour'] as List<dynamic>)
        .map((e) => HourModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
