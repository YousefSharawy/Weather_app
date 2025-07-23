// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:weather_app/core/di/register_module.dart' as _i731;
import 'package:weather_app/features/home/data/data_source/remote/weather_api_remote_data_source.dart'
    as _i106;
import 'package:weather_app/features/home/data/data_source/remote/weather_remote_data_source.dart'
    as _i381;
import 'package:weather_app/features/home/data/repository/weather_repository_impl.dart'
    as _i425;
import 'package:weather_app/features/home/domain/repositories/weather_repository.dart'
    as _i256;
import 'package:weather_app/features/home/domain/use_cases/get_weather.dart'
    as _i341;
import 'package:weather_app/features/home/representations/cubit/weather_cubit.dart'
    as _i307;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i381.WeatherRemoteDataSource>(
      () => _i106.CurrentWeatherApiRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i256.WeatherRepository>(
      () => _i425.WeatherRepositoryImpl(gh<_i381.WeatherRemoteDataSource>()),
    );
    gh.singleton<_i341.GetWeather>(
      () => _i341.GetWeather(gh<_i256.WeatherRepository>()),
    );
    gh.lazySingleton<_i307.WeatherCubit>(
      () => _i307.WeatherCubit(gh<_i341.GetWeather>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i731.RegisterModule {}
