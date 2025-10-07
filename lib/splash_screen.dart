import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_screen.dart';
import 'main.dart';
import 'screens/complete_profile_screen.dart';
import 'user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _fadeController.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    
    if (!mounted) return;
    
    // Check if user is already logged in
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      print('DEBUG: User already logged in: ${user.email ?? user.uid}');
      
      // Check if user needs to complete profile
      bool needsProfile = await _userService.needsProfileCompletion();
      
      if (needsProfile) {
        print('DEBUG: User needs to complete profile');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
        );
      } else {
        // User is logged in and profile is complete, go to home
        print('DEBUG: User logged in with complete profile, going to home');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Better App')),
        );
      }
    } else {
      // No user logged in, show onboarding
      print('DEBUG: No user logged in, showing onboarding');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // White background in case image doesn't fill
          Container(color: Colors.white),
          
          // Full screen splash image
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  // The splash image - fills width, aligns to bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'lib/assets/splash.png',
                      width: size.width,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  
                  // Gradient fade at top if needed for smooth blending
                  if (size.height > size.width * 1.8) // If screen is taller than image aspect
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
