import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/core/resources/assets_manager.dart';

class UIUtils {
  // static void showLoading(BuildContext context) => Lottie.asset(
  //   height: 100.h,
  //   width: 100.w,
  //   AssetsManager.loadingIndicator);

  //   static void showLoading(BuildContext context) => showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (_) => AlertDialog(
  //     content: SizedBox(
  //       height: MediaQuery.sizeOf(context).height * 0.2,
  //       child:  Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //          Lottie.asset(
  //   height: 100.h,
  //   width: 100.w,
  //       AssetsManager.loadingIndicator),
  //         ],
  //       ),
  //     ),
  //   ),
  // );
  static void showLoading(BuildContext context) {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Lottie.asset(
          height: 100.h,
          width: 100.w,
          AssetsManager.insider_loading,
        ),
      );
    });
  }

  static void hideLoading(BuildContext context) => Navigator.of(context).pop();

  static void showMessage(String message) =>
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
}
