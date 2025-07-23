import 'package:weather_app/features/home/data/mappers/condition_mapper.dart';
import 'package:weather_app/features/home/data/models/current_model.dart';
import 'package:weather_app/features/home/domain/entities/current.dart';

extension CurrentMapper on CurrentModel {
  Current get toEntity => Current(
    tempC: tempC,
    isDay: isDay,
    condition: condition.toEntity,
    humidity: humidity,
    cloud: cloud,
    windKph: windKph,
    windDegree: windDegree,
    windDir: windDir,
  );
}
