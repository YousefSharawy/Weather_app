import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:weather_app/core/shared/api_constants.dart';

@module  // Add this annotation!
abstract class RegisterModule {
  @singleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      receiveDataWhenStatusError: true,
      queryParameters: {
        "key": ApiConstants.apiKey,
      }
    ),
  );
}