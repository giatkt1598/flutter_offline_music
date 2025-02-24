import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.home});

  @override
  State<SplashPage> createState() => _SplashPageState();

  final Widget home;
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool _isShowSplash = true;
  final int fadeoutInMilliseconds = 500;
  final int splashTimeSeconds = 1;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: fadeoutInMilliseconds),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);

    Timer(Duration(seconds: splashTimeSeconds), () {
      _controller.forward();
      Timer(Duration(milliseconds: fadeoutInMilliseconds), () {
        setState(() {
          _isShowSplash = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF405C), // Màu nền
      body: Stack(
        children: [
          widget.home,
          if (_isShowSplash)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Color(0xFFFF405C),
                  ),
                  Image.asset(
                    "assets/splash.png",
                    width: 200, // Kích thước logo
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
