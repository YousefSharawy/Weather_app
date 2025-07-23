import 'package:weather_app/features/home/data/models/location_model.dart';
import 'package:weather_app/features/home/domain/entities/location.dart';

extension LocationMapper on LocationModel {
  Location get toEntity => Location(
        name: name,
      );
}
