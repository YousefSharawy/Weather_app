import 'package:flutter/material.dart';
import 'package:weather_app/core/routes/route_generator.dart';
import 'package:weather_app/core/routes/routes.dart';
import 'package:weather_app/core/shared/app_theme.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: Routes.splash,
      onGenerateRoute: RouteGenerator.getRoute,
    );
  }
}
