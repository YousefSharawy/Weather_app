import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:weather_app/core/error/failure.dart';
import 'package:weather_app/features/home/domain/entities/weather.dart';
import 'package:weather_app/features/home/domain/repositories/weather_repository.dart';

@singleton
class GetWeather {
  final WeatherRepository weatherRepository;
  GetWeather(this.weatherRepository);

  Future<Either<Failure, Weather>> call(String? cityName) =>
      weatherRepository.getCurrentWeather(cityName);
}
