import 'package:flutter/material.dart';
import 'package:weather_app/core/routes/routes.dart';
import 'package:weather_app/features/home/representations/screens/home_screen.dart';
import 'package:weather_app/features/splash_screen/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen());
    }
  }
}
