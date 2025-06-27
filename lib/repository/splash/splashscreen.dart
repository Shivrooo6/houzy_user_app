import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:houzy/repository/screens/login/loginscreen.dart';
import 'package:houzy/repository/screens/home/homescreen.dart';
import '../widgets/uihelper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _startFade = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start timer and handle navigation
    Timer(const Duration(seconds: 2), () async {
      setState(() => _startFade = true);
      await _controller.forward();

      final User? user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user != null) {
        // User logged in → navigate to HomeScreen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        // User not logged in → navigate to LoginScreen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
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
      backgroundColor: Appcolors.scaffoldbackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _startFade ? _fadeAnimation : AlwaysStoppedAnimation(1),
          child: Column(
            children: [
              // Top logo
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 5),
                child: Center(
                  child: SizedBox(
                    height: 120,
                    width: 250,
                    child: UiHelper.CustomImage(img: "houzylogoimage.png"),
                  ),
                ),
              ),
              // Splash image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 150),
                  child: Center(
                    child: SizedBox(
                      height: 800,
                      width: 250,
                      child: UiHelper.CustomImage(img: "splashimage1.png"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Appcolors {
  static var scaffoldbackground = Colors.white;
}
