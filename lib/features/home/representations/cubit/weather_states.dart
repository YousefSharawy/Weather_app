import 'package:weather_app/features/home/domain/entities/weather.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class CurrentWeatherLoading extends WeatherState {}

class CurrentWeatherLoaded extends WeatherState {
  final Weather weather;
  CurrentWeatherLoaded(this.weather);
}
class CurrentWeatherError extends WeatherState {
  final String message;

  CurrentWeatherError(this.message);
}
