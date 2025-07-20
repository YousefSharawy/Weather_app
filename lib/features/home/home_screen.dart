import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:weather_app/core/resources/assets_manager.dart';
import 'package:weather_app/core/resources/color_manager.dart';
import 'package:weather_app/core/resources/font_manager.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

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
      child: Scaffold(
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
                        padding:  EdgeInsets.only(left: 10.0.w,top: 2.h),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search",
                            suffixIcon: Icon(
                              Icons.search,
                              color: ColorManager.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Paris",
                    style: TextStyle(
                      fontSize: FontSizeManager.s24,
                      fontWeight: FontWeightManager.semiBold,
                      color: ColorManager.white.withValues(alpha: 0.75),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  "25°C",
                  style: TextStyle(
                    fontSize: FontSizeManager.s12,
                    fontWeight: FontWeightManager.regular,
                    color: ColorManager.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 25.h),

                Image.asset(AssetsManager.weatherAppIcon, width: 130.w),
                SizedBox(height: 25.h),
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
                                      colors: [Colors.white60, Colors.white10],
                                    ),
                                    color: ColorManager.white.withValues(
                                      alpha: 0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(25.r),
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
      ),
    );
  }
}
