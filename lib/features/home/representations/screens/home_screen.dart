import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weather_app/core/resources/color_manager.dart';
import 'package:weather_app/core/resources/font_manager.dart';
import 'package:weather_app/core/utilities/utiles.dart';
import 'package:weather_app/features/home/representations/cubit/weather_cubit.dart';
import 'package:weather_app/features/home/representations/cubit/weather_states.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
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
                        fontSize: FontSizeManager.s24,
                        fontWeight: FontWeightManager.semiBold,
                        color: ColorManager.white.withValues(alpha: 0.75),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${weatherCubit.currentWeather?.current.tempC.toString() ?? "0"}°C",
                          style: TextStyle(
                            fontSize: FontSizeManager.s12,
                            fontWeight: FontWeightManager.regular,
                            color: ColorManager.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    Image.network(
                      "https:${weatherCubit.currentWeather?.current.condition.icon ?? ""}",
                      width: 40.w,
                      height: 40.h,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox.shrink();
                      },
                    ),

                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.08.h,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          height: 300.h,
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
                              SizedBox(height: 10.h),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: days.length,
                                  itemBuilder: (_, index) {
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
                                              days[index],
                                              style: TextStyle(
                                                fontSize: FontSizeManager.s12,
                                                fontWeight:
                                                    FontWeightManager.regular,
                                                color: ColorManager.white
                                                    .withValues(alpha: 0.9),
                                              ),
                                            ),
                                            Text(
                                              "25°C",
                                              style: TextStyle(
                                                fontSize: FontSizeManager.s12,
                                                fontWeight:
                                                    FontWeightManager.regular,
                                                color: ColorManager.white
                                                    .withValues(alpha: 0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 5.h),
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
