import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:weather_app/core/error/exceptions.dart';
import 'package:weather_app/core/error/failure.dart';
import 'package:weather_app/features/home/data/data_source/remote/weather_remote_data_source.dart';
import 'package:weather_app/features/home/data/mappers/weather_mapper.dart';
import 'package:weather_app/features/home/domain/entities/weather.dart';
import 'package:weather_app/features/home/domain/repositories/weather_repository.dart';

@LazySingleton(as: WeatherRepository)
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource weatherRemoteDataSource;
  WeatherRepositoryImpl(this.weatherRemoteDataSource);
  @override
  Future<Either<Failure, Weather>> getCurrentWeather(String? cityName) async {
    try {
      final response = await weatherRemoteDataSource.getCurrentWeather(
        cityName,
      );
      return Right(response.toEntity);
    } on RemoteException catch (exception) {
      return Left(Failure(exception.message));
    }
  }
}
