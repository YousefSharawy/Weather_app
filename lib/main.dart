import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weather_app/core/routes/route_generator.dart';
import 'package:weather_app/core/routes/routes.dart';
import 'package:weather_app/core/shared/app_theme.dart';
import 'package:weather_app/core/di/service_locator.dart';
import 'package:weather_app/core/shared/bloc_observer.dart';
import 'package:weather_app/features/home/representations/cubit/weather_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  Bloc.observer = AppBlocObserver();
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt.get<WeatherCubit>(),
      child: ScreenUtilInit(
        splitScreenMode: true,
        minTextAdapt: true,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          initialRoute: Routes.splash,
          onGenerateRoute: RouteGenerator.getRoute,
        ),
      ),
    );
  }
}
