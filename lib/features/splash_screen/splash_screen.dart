import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/core/resources/assets_manager.dart';
import 'package:weather_app/core/resources/color_manager.dart';
import 'package:weather_app/features/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> topRight;
  late Animation<Alignment> bottomLeft;
@override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this ,duration: Duration(seconds: 10));
    topRight = TweenSequence <Alignment> ([
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight , end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight , end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomLeft , end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft , end: Alignment.topRight), weight: 1),
    ]).animate(_controller);
    bottomLeft = TweenSequence <Alignment> ([
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomLeft , end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft , end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight , end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight , end: Alignment.bottomLeft), weight: 1),
    ]).animate(_controller);

    _controller.repeat();
  }
   @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context,_) { 
       return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: topRight.value,
            end: bottomLeft.value,
            colors: [ColorManager.lightPurple,ColorManager.darkerPurple],
          ),
        ),
        child: AnimatedSplashScreen(
          duration: 3200,
          backgroundColor: Colors.transparent,
          splashIconSize: 300,
          splash: LottieBuilder.asset(AssetsManager.loadingIndicator),
          nextScreen: HomeScreen(),
        ),
      );
       },
    );
  }
}
