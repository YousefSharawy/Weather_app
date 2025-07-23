import 'package:weather_app/features/home/data/mappers/forecastday_mapper.dart';
import 'package:weather_app/features/home/data/models/forecast_response.dart';
import 'package:weather_app/features/home/domain/entities/forecast.dart';

extension ForecastMapper on ForecastResponse {
  Forecast get toEntity => Forecast(
    forecastday: forecastday.map((e) => e.toEntity).toList(), 
  );
}