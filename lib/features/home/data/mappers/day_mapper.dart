import 'package:weather_app/features/home/data/mappers/condition_mapper.dart';
import 'package:weather_app/features/home/data/models/day_model.dart';
import 'package:weather_app/features/home/domain/entities/day.dart';

extension DayMapper on DayModel {

  Day get toEntity => Day(
    maxtempC: maxtempC,
    maxtempF: maxtempF,
    mintempC: mintempC,
    mintempF: mintempF, condition: condition.toEntity,
   
  );
}