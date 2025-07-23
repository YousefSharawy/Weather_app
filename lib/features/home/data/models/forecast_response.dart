import 'package:weather_app/features/home/data/models/forecastday_model.dart';

class ForecastResponse {
  final List<ForecastdayModel> forecastday; 

  const ForecastResponse({required this.forecastday});

  factory ForecastResponse.fromJson(Map<String, dynamic> json) => ForecastResponse(
    forecastday: (json['forecastday'] as List<dynamic>) // Changed key name
        .map((e) => ForecastdayModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}