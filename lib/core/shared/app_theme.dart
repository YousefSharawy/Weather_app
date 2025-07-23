import 'package:flutter/material.dart';
import 'package:weather_app/core/resources/color_manager.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: ColorManager.white.withValues(alpha: 0.7)),
      labelStyle: TextStyle(color: ColorManager.white.withValues(alpha: 0.7)),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: ColorManager.transparent),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: ColorManager.transparent),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: ColorManager.transparent),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      onSurface: ColorManager.white, 

      seedColor: ColorManager.white,
      primary: ColorManager.white,
    ),
  );
}
