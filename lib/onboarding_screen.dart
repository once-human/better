import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart';
import 'dart:math' as math;
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  int currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _parallaxController;
  late AnimationController _buttonScaleController;
  late AnimationController _indicatorController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _parallaxAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _textSlideAnimation;
  
  bool _isTransitioning = false;
  double _dragStart = 0;
  double _dragDistance = 0;
  
  // Spring physics for gestures
  final SpringDescription _spring = const SpringDescription(
    mass: 1,
    stiffness: 100,
    damping: 15,
  );

  final List<OnboardingData> onboardingData = [
    OnboardingData(
      image: 'lib/assets/onboarding/1.png',
      text: 'A friend that doesn\'t let you feel alone in your healing journey',
    ),
    OnboardingData(
      image: 'lib/assets/onboarding/2.png',
      text: 'A fireplace to burn up all those negative feelings',
    ),
    OnboardingData(
      image: 'lib/assets/onboarding/3.png',
      text: 'Share your life story, mementos\nand leave behind a digital legacy\nfor your loved ones',
      isLastScreen: true,
    ),
    OnboardingData(
      image: 'lib/assets/onboarding/4.png',
      text: 'A garden where you grow\nflowers by tracking a habit\neveryday',
    ),
    OnboardingData(
      image: 'lib/assets/onboarding/5.png',
      text: 'A place where you can speak your heart out without being judged',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _buttonScaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Setup animations with custom curves
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: const Cubic(0.4, 0.0, 0.2, 1.0), // Material Design standard curve
    );
    
    _parallaxAnimation = CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeOutCubic,
    );
    
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonScaleController,
      curve: Curves.easeInOut,
    ));
    
    _textSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));
    
    // Start with animation visible
    _fadeController.value = 1.0;
    
    // Trigger haptic on load
    HapticFeedback.selectionClick();
    
    // Keep status bar visible but make it transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _navigateToAuth() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Sophisticated Apple-style animation
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var slideAnimation = animation.drive(slideTween);

          var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut));
          var fadeAnimation = animation.drive(fadeTween);

          var scaleTween = Tween(begin: 0.98, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic));
          var scaleAnimation = animation.drive(scaleTween);

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildOnboardingPage(onboardingData[currentPage]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: Row(
        children: [
          // Hamburger menu
          Icon(
            Icons.menu,
            color: Colors.grey[800],
            size: 24,
          ),
          const SizedBox(width: 15), // Small spacing
          // Logo immediately after hamburger
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5C6C6), // Light pink
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'lib/assets/better_navlogo.png',
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(), // Push profile icon to the right
          // Profile icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!, width: 1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _dragStart = details.globalPosition.dx;
        _buttonScaleController.forward();
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragDistance = details.globalPosition.dx - _dragStart;
        });
      },
      onHorizontalDragEnd: (details) {
        _buttonScaleController.reverse();
        final velocity = details.primaryVelocity ?? 0;
        
        // Swipe threshold with velocity consideration
        if (_dragDistance.abs() > 100 || velocity.abs() > 500) {
          if (_dragDistance > 0 && currentPage > 0) {
            _previousPage();
            HapticFeedback.lightImpact();
          } else if (_dragDistance < 0 && currentPage < onboardingData.length - 1) {
            _nextPage();
            HapticFeedback.lightImpact();
          }
        }
        
        setState(() {
          _dragDistance = 0;
        });
      },
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Full-width main image with parallax effect - now fullscreen
          Positioned(
            top: 0, // Start from top of screen (under status bar)
            left: 0,
            right: 0,
            bottom: 200,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: const Cubic(0.4, 0.0, 0.2, 1.0),
              switchOutCurve: const Cubic(0.4, 0.0, 1, 1),
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Multi-layered transition
                final fadeAnimation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
                ));

                final scaleAnimation = Tween<double>(
                  begin: 1.05,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const SpringCurve(),
                ));
                
                final slideAnimation = Tween<Offset>(
                  begin: Offset(_isTransitioning ? 0.05 : -0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ));

                return FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: Transform.translate(
                        offset: Offset(_dragDistance * 0.2, 0), // Parallax on drag
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: Image.asset(
                data.image,
                key: ValueKey<String>(data.image),
                fit: BoxFit.cover,
                width: double.infinity,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        // Bottom card overlay with fade animation
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 250,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFBF1F0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text content with fixed height container
                SizedBox(
                  height: 100, // Fixed height for text area
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      switchInCurve: const Cubic(0.4, 0.0, 0.2, 1.0),
                      switchOutCurve: const Cubic(0.4, 0.0, 1, 1),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        // Staggered text animation
                        final fadeAnimation = Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                        ));

                        final slideAnimation = Tween<Offset>(
                          begin: const Offset(0.0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
                        ));
                        
                        final scaleAnimation = Tween<double>(
                          begin: 0.95,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
                        ));

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: slideAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Transform.translate(
                        offset: Offset(_dragDistance * 0.1, 0), // Subtle parallax
                        child: Text(
                          data.text,
                          key: ValueKey<String>(data.text),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C2C2C),
                            height: 1.4,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Navigation controls with fixed height container
                SizedBox(
                  height: 50, // Fixed height for navigation area
                  child: currentPage == 4
                      ? Center(
                          child: GestureDetector(
                            onTap: _navigateToAuth,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOutCubic,
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDA6666),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFDA6666).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Previous button with fixed container
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: AnimatedOpacity(
                                opacity: currentPage > 0 ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: GestureDetector(
                                  onTap: currentPage > 0 ? _previousPage : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Page indicators
                            Row(
                              children: List.generate(5, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOutCubic,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: currentPage == index ? 24 : 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: currentPage == index 
                                        ? const Color(0xFFDA6666) 
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                );
                              }),
                            ),
                            // Next button with fixed container
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: _nextPage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  void _nextPage() {
    if (currentPage < onboardingData.length - 1 && !_isTransitioning) {
      HapticFeedback.selectionClick();
      setState(() {
        _isTransitioning = true;
        currentPage++;
      });
      
      // Trigger indicator animation
      _indicatorController.forward().then((_) {
        _indicatorController.reset();
      });
      
      // Reset transition flag after animation completes
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isTransitioning = false;
          });
        }
      });
    }
  }

  void _previousPage() {
    if (currentPage > 0 && !_isTransitioning) {
      HapticFeedback.selectionClick();
      setState(() {
        _isTransitioning = true;
        currentPage--;
      });
      
      // Trigger indicator animation
      _indicatorController.forward().then((_) {
        _indicatorController.reset();
      });
      
      // Reset transition flag after animation completes
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isTransitioning = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _parallaxController.dispose();
    _buttonScaleController.dispose();
    _indicatorController.dispose();
    // Restore status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }
}

class OnboardingData {
  final String image;
  final String text;
  final bool isLastScreen;

  OnboardingData({
    required this.image,
    required this.text,
    this.isLastScreen = false,
  });
}

// Custom Spring curve for natural animations
class SpringCurve extends Curve {
  const SpringCurve();
  
  @override
  double transform(double t) {
    const double c4 = (2 * 3.14159) / 3;
    return t == 0
        ? 0
        : t == 1
            ? 1
            : -math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }
}

