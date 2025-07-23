import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:weather_app/core/error/exceptions.dart';
import 'package:weather_app/core/shared/api_constants.dart';
import 'package:weather_app/features/home/data/data_source/remote/weather_remote_data_source.dart';
import 'package:weather_app/features/home/data/models/weatehr_model.dart';

@LazySingleton(as: WeatherRemoteDataSource)
class CurrentWeatherApiRemoteDataSource implements WeatherRemoteDataSource {
  final Dio dio;
  CurrentWeatherApiRemoteDataSource(this.dio);

  @override
  Future<WeatherModel> getCurrentWeather(String? cityName) async {
    try {
      final response = await dio.get(
        ApiConstants.forecastWeatherEndpoint,
        queryParameters: {"q": cityName ?? "Egypt"},
      );
      return WeatherModel.fromJson(response.data);
    } catch (exception) {
      String? message;
      if (exception is DioException) {
        message = exception.response?.data['message'];
      }
      throw RemoteException(message ?? "Failed to fetch current weather");
    }
  }
}
