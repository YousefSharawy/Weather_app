import 'package:weather_app/features/home/data/mappers/current_mapper.dart';
import 'package:weather_app/features/home/data/mappers/location_mapper.dart';
import 'package:weather_app/features/home/data/models/weatehr_model.dart';
import 'package:weather_app/features/home/domain/entities/weather.dart';

extension WeatherMapper on WeatherModel {

Weather get toEntity => Weather (
  location: location.toEntity,
    current: current.toEntity,
);
}


