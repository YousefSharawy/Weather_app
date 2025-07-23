import 'package:weather_app/features/home/data/models/weatehr_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(String? cityName);
}
