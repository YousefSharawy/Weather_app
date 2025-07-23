import 'package:weather_app/features/home/domain/entities/forecastday.dart';

class Forecast {
  final List<Forecastday> forecastday; 

  const Forecast({required this.forecastday});
}