import 'package:weather_app/features/home/domain/entities/astro.dart';
import 'package:weather_app/features/home/domain/entities/day.dart';
import 'package:weather_app/features/home/domain/entities/hour.dart';

class Forecastday {
   final Day day;
    final Astro astro;
   final List<Hour> hour;

   Forecastday({
    required this.day,
    required this.astro,
    required this.hour,
  });
}