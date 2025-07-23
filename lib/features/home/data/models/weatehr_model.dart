import 'package:weather_app/features/home/data/models/forecast_response.dart';

import 'current_model.dart';
import 'location_model.dart';

class WeatherModel {
  final LocationModel location;
  final CurrentModel current;
  final ForecastResponse forecast;

  const WeatherModel({required this.location, required this.current, required this.forecast});

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      forecast: ForecastResponse.fromJson(json['forecast'] as Map<String, dynamic>),
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      current: CurrentModel.fromJson(json['current'] as Map<String, dynamic>),
    );
  }
}
