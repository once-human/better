import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SweepGradient(
            center: Alignment.center,
            startAngle: 0.0,
            endAngle: 2 * 3.14159, // 2π for full circle
            colors: [
              Color(0xFFE1DDF7), // Light purple/blue at 6%
              Color(0xFFE1DDF7), // Light purple/blue at 6%
              Color(0xFFFBF1F0), // Off-white at 72%
              Color(0xFFFBF1F0), // Off-white at 72%
            ],
            stops: [0.0, 0.06, 0.72, 1.0],
          ),
        ),
        child: const Center(
          child: Image(
            image: AssetImage('lib/assets/splash.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
