import 'package:weather_app/features/home/data/models/condition_model.dart';
import 'package:weather_app/features/home/domain/entities/condition.dart';

extension ConditionMapper on ConditionModel {
  Condition get toEntity => Condition(icon: icon);
}
