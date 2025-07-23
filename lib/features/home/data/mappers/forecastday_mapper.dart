import 'package:weather_app/features/home/data/mappers/astro_mapper.dart';
import 'package:weather_app/features/home/data/mappers/day_mapper.dart';
import 'package:weather_app/features/home/data/mappers/hour_mapper.dart';
import 'package:weather_app/features/home/data/models/forecastday_model.dart';
import 'package:weather_app/features/home/domain/entities/forecastday.dart'; // Add this import

extension ForecastdayMapper on ForecastdayModel {
  Forecastday get toEntity => Forecastday( 
    day: day.toEntity,
    astro: astro.toEntity,
    hour: hour.map((e) => e.toEntity).toList(),
  );
}