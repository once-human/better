import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart';
import 'user_service.dart';
import 'screens/profile_screen.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _userName = ''; // No default, always fetch actual name
  final UserService _userService = UserService();
  bool _isRefreshing = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _loadUserName();

    // Keep status bar visible but make it transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _loadUserName() async {
    String? name = await _userService.getUserName();
    if (name != null && name.isNotEmpty && mounted) {
      // Extract first name only
      String firstName = name.split(' ').first;
      setState(() {
        _userName = firstName;
      });
    } else {
      // Try to get from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.displayName != null && mounted) {
        String firstName = user.displayName!.split(' ').first;
        setState(() {
          _userName = firstName;
        });
      }
    }
  }
  
  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Reload user name
    await _loadUserName();
    
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Fixed header at top
          _buildHeader(),
          // Scrollable content below
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                HapticFeedback.selectionClick();
              },
              physics: const ClampingScrollPhysics(),
              children: [
                _buildHomeContent(),
                _buildCommunityPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCurvedBottomNav(),
    );
  }
  
  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFFDA6666),
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 2.5,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message - only show if name is loaded
                if (_userName.isNotEmpty)
                  Text(
                    'Welcome $_userName,',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  )
                else
                  const SizedBox(height: 32),
                const SizedBox(height: 24),
                // Grid of cards
                _buildCardsGrid(),
                const SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),
          // Floating Create Memoir Button
          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: _buildCreateMemoirButton(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommunityPage() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Community',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<String?>(
      future: _userService.getBestProfilePicture(),
      builder: (context, snapshot) {
        final profilePicUrl = snapshot.data;
        final hasProfileImage = profilePicUrl != null && profilePicUrl.isNotEmpty;
        
        return Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 14, // Reduced from +16
            left: 24, // Reduced from 28
            right: 24, // Reduced from 28
            bottom: 14, // Reduced from 16
          ),
          child: Row(
            children: [
              // Hamburger menu - reduced from 36 to 31
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  // Add menu functionality
                },
                child: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF2C2C2C),
                  size: 31, // Reduced from 36
                ),
              ),
              const SizedBox(width: 20), // Reduced from 24
              // Logo with text - reduced from 45 to 38 height
              Image.asset(
                'lib/assets/better_navlogo.png',
                height: 38, // Reduced from 45
                fit: BoxFit.contain,
              ),
              const Spacer(),
              // Right: Profile button - reduced from 48 to 41
              GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                  // Reset to home when coming back from profile
                  if (mounted) {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  }
                },
                child: Container(
                  width: 41, // Reduced from 48
                  height: 41, // Reduced from 48
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1.9, // Reduced from 2.25 (0.85x)
                    ),
                  ),
                  child: hasProfileImage
                      ? ClipOval(
                          child: profilePicUrl!.startsWith('http')
                              ? Image.network(
                                  profilePicUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF2C2C2C),
                                    size: 23, // Reduced from 27 (0.85x)
                                  ),
                                )
                              : Image.file(
                                  File(profilePicUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF2C2C2C),
                                    size: 23, // Reduced from 27 (0.85x)
                                  ),
                                ),
                        )
                      : const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF2C2C2C),
                          size: 23, // Reduced from 27 (0.85x)
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardsGrid() {
    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(child: _buildIllustratedCard(
              'Get\nClosure',
              const Color(0xFFE8DDD4),
              Icons.self_improvement,
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildIllustratedCard(
              'Your\nVenting\nCorner',
              const Color(0xFFD4C4B0),
              Icons.chat_bubble_outline,
            )),
          ],
        ),
        const SizedBox(height: 16),
        // Second row
        Row(
          children: [
            Expanded(child: _buildIllustratedCard(
              'Set your\nReminders',
              const Color(0xFFC8D5B9),
              Icons.alarm,
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildIllustratedCard(
              'Your favourite\nMemories',
              const Color(0xFFCFB3A6),
              Icons.photo_album_outlined,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildIllustratedCard(String title, Color backgroundColor, IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        // Add navigation to respective feature
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icon decoration
            Positioned(
              top: 20,
              right: 20,
              child: Icon(
                icon,
                size: 60,
                color: backgroundColor.withOpacity(0.3),
              ),
            ),
            // Title
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateMemoirButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Add create memoir functionality
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFAD8D6), // Light pink color
          borderRadius: BorderRadius.circular(50), // Much more rounded
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create a Memoir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFFFAD8D6),
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedBottomNav() {
    return Container(
      height: 60, // Reduced from 85
      decoration: const BoxDecoration(
        color: Color(0xFFFBF1F0), // Exact color from screenshot
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35), // Reduced from 50
          topRight: Radius.circular(35), // Reduced from 50
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Home icon
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
              ),
              const SizedBox(width: 80), // Reduced space between icons
              // Community icon
              _buildNavItem(
                index: 1,
                icon: Icons.people_outline,
                activeIcon: Icons.people,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    // Check if it's one of the main nav items (0 or 1)
    final isSelected = _selectedIndex == index && index < 2;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (index < 2) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6), // Reduced from 8
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFFDA6666) : Colors.grey[600],
              size: 24, // Increased to 1.2x of 20
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4), // Reduced from 6
                width: 4, // Reduced from 6
                height: 4, // Reduced from 6
                decoration: const BoxDecoration(
                  color: Color(0xFFDA6666),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 8), // Reduced from 12
          ],
        ),
      ),
    );
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
