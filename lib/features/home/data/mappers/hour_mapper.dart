import 'package:weather_app/features/home/data/mappers/condition_mapper.dart';
import 'package:weather_app/features/home/data/models/hour_model.dart';
import 'package:weather_app/features/home/domain/entities/hour.dart';

extension HourMapper on HourModel {
  Hour get toEntity => Hour(
    time: time,
    tempC: tempC, condition: condition.toEntity,
    
  );
}