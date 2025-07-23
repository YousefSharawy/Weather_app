
import 'current_model.dart';
import 'location_model.dart';

class WeatherModel {
  final LocationModel location;
  final CurrentModel current;

  const WeatherModel({required this.location, required this.current});

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      current:  CurrentModel.fromJson(json['current'] as Map<String, dynamic>),
    );
  }

  
}
