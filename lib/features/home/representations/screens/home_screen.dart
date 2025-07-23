import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weather_app/core/resources/assets_manager.dart';
import 'package:weather_app/core/resources/color_manager.dart';
import 'package:weather_app/core/resources/font_manager.dart';
import 'package:weather_app/core/utilities/utiles.dart';
import 'package:weather_app/features/home/representations/cubit/weather_cubit.dart';
import 'package:weather_app/features/home/representations/cubit/weather_states.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();

  late final WeatherCubit weatherCubit;
  late String? cityName;
  @override
  void initState() {
    super.initState();
    weatherCubit = context.read<WeatherCubit>();
    Future.delayed(Duration.zero, () {
      weatherCubit.fetchCurrentWeather("Egypt");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [ColorManager.lightPurple, ColorManager.darkerPurple],
        ),
      ),
      child: BlocConsumer<WeatherCubit, WeatherState>(
        listener: (context, state) {
          if (state is CurrentWeatherLoading) {
            UIUtils.showLoading(context);
          } else if (state is CurrentWeatherError) {
            UIUtils.hideLoading(context);
            UIUtils.showMessage(state.message);
          } else if (state is CurrentWeatherLoaded) {
            UIUtils.hideLoading(context);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorManager.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          height: 40.h,
                          width: 300.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white60, Colors.white10],
                            ),
                            color: ColorManager.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(
                              width: 2.w,
                              color: ColorManager.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.0.w, top: 2.h),
                            child: TextField(
                              controller: searchController,
                              onSubmitted: (value) {
                                weatherCubit.fetchCurrentWeather(value);
                                if (value.trim().isEmpty) {
                                  weatherCubit.fetchCurrentWeather("Egypt");
                                }
                              },
                              onChanged: (value) {
                                if (value.trim().isEmpty) {
                                  weatherCubit.fetchCurrentWeather("Egypt");
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Search",
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: ColorManager.white.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      weatherCubit.currentWeather?.location.name ?? "Unknown",
                      style: TextStyle(
                        fontSize: FontSizeManager.s28,
                        fontWeight: FontWeightManager.bold,
                        fontFamily: "FjallaOne",
                        color: ColorManager.white.withValues(alpha: 0.75),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https:${weatherCubit.currentWeather?.current.condition.icon ?? ""}",
                          width: 40.w,
                          height: 40.h,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                    Text(
                      "${weatherCubit.currentWeather?.current.tempC.toString() ?? "0"} °C",
                      style: TextStyle(
                        fontFamily: "FjallaOne",
                        fontSize: FontSizeManager.s40,
                        fontWeight: FontWeightManager.regular,
                        color: ColorManager.white.withValues(alpha: 0.9),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          height: 60.h,
                          width: 300.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white60, Colors.white10],
                            ),
                            color: ColorManager.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(
                              width: 2.w,
                              color: ColorManager.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 5.h),

                                  Image.asset(
                                    AssetsManager.humidity,
                                    height: 30.h,
                                    width: 30.w,
                                  ),
                                 Text(" ${weatherCubit.currentWeather?.current.humidity  ?? 0} %",style: TextStyle(fontWeight: FontWeightManager.bold),)
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: VerticalDivider(
                                  color: ColorManager.white,
                                ),
                              ),
                               Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 5.h),

                                 Image.asset(
                                    AssetsManager.wind,
                                    height: 30.h,
                                    width: 30.w,
                                    matchTextDirection: true,
                                  ),
                                 Text(" ${weatherCubit.currentWeather?.current.windKph  ?? 0} km/h",style: TextStyle(fontWeight: FontWeightManager.bold),)
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: VerticalDivider(
                                  color: ColorManager.white,
                                ),
                              ),
                               Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 5.h),

                                  Image.asset(
                                    AssetsManager.windDirection,
                                    height: 30.h,
                                    width: 30.w,
                                  ),
                                 Text(" ${weatherCubit.currentWeather?.current.windDir?? ""}",style: TextStyle(fontWeight: FontWeightManager.bold),)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 35.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          height: 250.h,
                          width: 300.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white60, Colors.white10],
                            ),
                            color: ColorManager.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(
                              width: 2.w,
                              color: ColorManager.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount:
                                      weatherCubit
                                          .currentWeather
                                          ?.forecast
                                          .forecastday
                                          .first
                                          .hour
                                          .length ??
                                      0,
                                  itemBuilder: (_, index) {
                                    final hourData = weatherCubit
                                        .currentWeather
                                        ?.forecast
                                        .forecastday
                                        .first
                                        .hour[index];

                                    if (hourData == null) {
                                      return SizedBox.shrink();
                                    }

                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 7.w,
                                        vertical: 5.h,
                                      ),
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white60,
                                            Colors.white10,
                                          ],
                                        ),
                                        color: ColorManager.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          25.r,
                                        ),
                                        border: Border.all(
                                          width: 2.w,
                                          color: ColorManager.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.0.w,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              hourData.time.split(' ').last,
                                              style: TextStyle(
                                                fontSize: FontSizeManager.s12,
                                                fontWeight:
                                                    FontWeightManager.regular,
                                                color: ColorManager.white
                                                    .withValues(alpha: 0.9),
                                              ),
                                            ),
                                            Text(
                                              "${hourData.tempC}°C",
                                              style: TextStyle(
                                                fontSize: FontSizeManager.s12,
                                                fontWeight:
                                                    FontWeightManager.regular,
                                                color: ColorManager.white
                                                    .withValues(alpha: 0.9),
                                              ),
                                            ),
                                            Image.network(
                                              "https:${hourData.condition.icon}",
                                              width: 30.w,
                                              height: 30.h,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return SizedBox.shrink();
                                                  },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
