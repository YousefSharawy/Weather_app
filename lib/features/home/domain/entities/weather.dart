import 'package:weather_app/features/home/domain/entities/current.dart';
import 'package:weather_app/features/home/domain/entities/location.dart';

class Weather {
  final Location location;
  final Current current;
  const Weather({required this.location, required this.current});
}
