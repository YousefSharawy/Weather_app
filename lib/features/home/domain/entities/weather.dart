import 'package:weather_app/features/home/domain/entities/current.dart';
import 'package:weather_app/features/home/domain/entities/forecast.dart';
import 'package:weather_app/features/home/domain/entities/location.dart';

class Weather {
  final Location location;
  final Current current;
  final Forecast forecast;
  
  const Weather({required this.location, required this.current ,required this.forecast,});
}
