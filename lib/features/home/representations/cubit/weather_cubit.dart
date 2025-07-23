import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:weather_app/features/home/domain/entities/weather.dart';
import 'package:weather_app/features/home/domain/use_cases/get_weather.dart';
import 'package:weather_app/features/home/representations/cubit/weather_states.dart';

@lazySingleton
class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this.getWeatherUseCase) : super(WeatherInitial());

  final GetWeather getWeatherUseCase;
    Weather ? currentWeather;

  Future<void> fetchCurrentWeather(String cityName) async {
    emit(CurrentWeatherLoading());
    final result = await getWeatherUseCase(cityName);
    result.fold((failure) => emit(CurrentWeatherError(failure.message)), ((
      weather,
    ) {
      currentWeather = weather;
      emit(CurrentWeatherLoaded(weather));
    }));
  }
}