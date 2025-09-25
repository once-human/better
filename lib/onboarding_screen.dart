import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();

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
    // Keep status bar visible but make it transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Visible header/navbar
          _buildHeader(),
          // Main content with PageView
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(onboardingData[index]);
                  },
                ),
                // Bottom navigation overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomNavigation(),
                ),
              ],
            ),
          ),
        ],
      ),
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
    return Stack(
      children: [
        // Full-width main image starting from top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 200, // Stop before the rounded card starts
          child: Image.asset(
            data.image,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        // Bottom card overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 250, // Increased height
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFBF1F0), // Updated color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text content
                Text(
                  data.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w500, // Medium
                    color: Color(0xFF2C2C2C),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),
                // Navigation controls
                currentPage == 4
                    ? // Last page - only Get Started button
                      Center(
                          child: GestureDetector(
                            onTap: _nextPage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOutCubic,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                    : // Other pages - normal navigation
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous button (only show if not on first page)
                            currentPage > 0
                                ? GestureDetector(
                                    onTap: _previousPage,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      width: 40,
                                      height: 40,
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
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                  ),
                            // Page indicators
                            Row(
                              children: List.generate(4, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: currentPage == index ? Colors.red : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                            // Next button
                            GestureDetector(
                              onTap: _nextPage,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 100, // Space for bottom navigation
    );
  }

  void _nextPage() {
    if (currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Navigate to main app with sophisticated Apple-level animation
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MyHomePage(title: 'Better App'),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Sophisticated Apple-style animation
            const begin = Offset(0.0, 0.1);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            // Subtle slide up animation
            var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var slideAnimation = animation.drive(slideTween);

            // Smooth fade in
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut));
            var fadeAnimation = animation.drive(fadeTween);

            // Subtle scale animation (very minimal)
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
          transitionDuration: const Duration(milliseconds: 600), // Smooth and quick
        ),
      );
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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
