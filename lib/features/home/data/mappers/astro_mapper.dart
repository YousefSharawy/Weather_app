import 'package:weather_app/features/home/data/models/astro_model.dart';
import 'package:weather_app/features/home/domain/entities/astro.dart';

extension AstroMapper on AstroModel {
  Astro get toEntity => Astro(
    sunrise: sunrise,
    sunset: sunset,
    moonrise: moonrise,
    moonset: moonset,
  );
}
