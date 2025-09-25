import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';

void main() {
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
          // Header/Navbar
          _buildHeader(),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  const Text(
                    'Welcome Khushi,',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20, // Much smaller - about 1/3rd
                      fontWeight: FontWeight.w500, // Medium
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 20), // Reduced spacing
                  // Grid of cards (placeholder for now)
                  _buildCardsGrid(),
                  const SizedBox(height: 30),
                  // Create a Memoir button
                  _buildCreateMemoirButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Curved bottom navigation bar
      bottomNavigationBar: _buildCurvedBottomNav(),
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

  Widget _buildCardsGrid() {
    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(child: _buildCard('Get Closure', 'Get')),
            const SizedBox(width: 22), // Increased spacing to match screenshot
            Expanded(child: _buildCard('Your Venting Corner', 'Your')),
          ],
        ),
        const SizedBox(height: 22), // Increased spacing to match screenshot
        // Second row
        Row(
          children: [
            Expanded(child: _buildCard('Set your Reminders', 'Set your')),
            const SizedBox(width: 22), // Increased spacing to match screenshot
            Expanded(child: _buildCard('Your favourite Memories', 'Your favourite')),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String title, String subtitle) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25), // More rounded cards
      ),
      child: Stack(
        children: [
          // Placeholder for illustration
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25), // More rounded
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          // Text overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // More rounded text overlay
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
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

  Widget _buildCreateMemoirButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAD8D6), // New color as specified
        borderRadius: BorderRadius.circular(50), // Much more rounded corners
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Text left, plus button right
        children: [
          const Text(
            'Create a Memoir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFFFAD8D6), // Same color as card
              border: Border.all(color: Colors.white, width: 2), // White border/circle
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
    );
  }

  Widget _buildCurvedBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBF1F0), // Exact color from screenshot
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50), // Much more curved
          topRight: Radius.circular(50), // Much more curved
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 60, // Much shorter
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Row(
                  children: [
                    // 30% space from left
                    Expanded(flex: 3, child: SizedBox()),
                    // Home icon with larger click area
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12), // Larger click area but not too big
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home,
                              color: _selectedIndex == 0 ? const Color(0xFFDA6666) : Colors.grey[600],
                              size: 28,
                            ),
                            if (_selectedIndex == 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // 40% space between icons (increased from 20%)
                    Expanded(flex: 4, child: SizedBox()),
                    // Community icon with larger click area
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12), // Larger click area but not too big
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.group,
                              color: _selectedIndex == 1 ? const Color(0xFFDA6666) : Colors.grey[600],
                              size: 28,
                            ),
                            if (_selectedIndex == 1)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // 30% space from right
                    Expanded(flex: 3, child: SizedBox()),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
