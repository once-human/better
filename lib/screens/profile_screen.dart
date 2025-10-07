import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../user_service.dart';
import '../models/user_profile.dart';
import '../auth_screen.dart';
import 'complete_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final UserService _userService = UserService();
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isGuest = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfile() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      _isGuest = user?.isAnonymous ?? false;
      
      final profile = await _userService.getUserFullProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.signOut();
                await _userService.clearUserData();
                Navigator.pushNamed(context, '/auth');
                
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    if (_profile == null) return;
    
    final updatedProfile = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (context) => CompleteProfileScreen(
          isEditing: true,
          existingProfile: _profile,
        ),
      ),
    );
    
    if (updatedProfile != null) {
      setState(() {
        _profile = updatedProfile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFFDA6666)),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFDA6666),
                  strokeWidth: 2.5,
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header Card - Full Width White Design
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 50,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Photo - Prominent but not overwhelming
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFDA6666).withOpacity(0.15),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDA6666).withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _profile?.photoUrl != null
                                      ? (_profile!.photoUrl!.startsWith('http')
                                          ? Image.network(
                                              _profile!.photoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                            )
                                          : Image.file(
                                              File(_profile!.photoUrl!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                            ))
                                      : _buildDefaultAvatar(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Name
                            Text(
                              _profile?.fullName ?? 'Guest User',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C2C2C),
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            // Email
                            Text(
                              _profile?.email ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Account Type Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getAccountTypeColor(),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getAccountTypeIcon(),
                                    size: 14,
                                    color: _getAccountTypeTextColor(),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getAccountTypeText(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getAccountTypeTextColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_profile?.bio != null && _profile!.bio!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _profile!.bio!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2C2C2C),
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Profile Info Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Personal Information'),
                            const SizedBox(height: 16),
                            _buildModernInfoCard(
                              icon: Icons.cake_outlined,
                              title: 'Birthday',
                              value: _profile?.dateOfBirth != null
                                  ? DateFormat('dd MMMM yyyy').format(_profile!.dateOfBirth)
                                  : 'Not set',
                              subtitle: _profile?.age != null
                                  ? '${_profile!.age} years old'
                                  : null,
                              isEditable: true,
                              onEdit: () => _editBirthday(),
                            ),
                            const SizedBox(height: 12),
                            _buildModernInfoCard(
                              icon: Icons.info_outline,
                              title: 'Bio',
                              value: _profile?.bio ?? 'No bio added',
                              isExpandable: true,
                              isEditable: true,
                              onEdit: () => _editBio(),
                            ),

                            const SizedBox(height: 32),
                            _buildSectionTitle('Account Information'),
                            const SizedBox(height: 16),
                            _buildModernInfoCard(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              value: _profile?.email ?? 'Not available',
                            ),
                            const SizedBox(height: 12),
                            _buildModernInfoCard(
                              icon: Icons.access_time,
                              title: 'Member Since',
                              value: _profile?.createdAt != null
                                  ? DateFormat('MMMM yyyy').format(_profile!.createdAt)
                                  : 'Unknown',
                            ),

                            // Show upgrade option for guest users
                            if (_isGuest) ...[
                              const SizedBox(height: 32),
                              _buildUpgradeSection(),
                            ],

                            const SizedBox(height: 32),
                            _buildSectionTitle('Settings'),
                            const SizedBox(height: 16),
                            _buildModernSettingsTile(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              subtitle: 'Manage notification preferences',
                              onTap: () => _showNotificationSettings(),
                            ),
                            _buildModernSettingsTile(
                              icon: Icons.lock_outline,
                              title: 'Privacy',
                              subtitle: 'Control your privacy settings',
                              onTap: () => _showPrivacySettings(),
                            ),
                            _buildModernSettingsTile(
                              icon: Icons.help_outline,
                              title: 'Help & Support',
                              subtitle: 'Get help or contact support',
                              onTap: () => _showHelpSupport(),
                            ),
                            _buildModernSettingsTile(
                              icon: Icons.info_outline,
                              title: 'About',
                              subtitle: 'Version 1.0.2',
                              onTap: () => _showAbout(),
                            ),
                            _buildModernSettingsTile(
                              icon: Icons.logout,
                              title: 'Sign Out',
                              subtitle: 'Sign out of your account',
                              onTap: _signOut,
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
  
  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }
  
  Widget _buildModernInfoCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    bool isExpandable = false,
    bool isEditable = false,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDA6666).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFDA6666),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C2C2C),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: isExpandable ? null : 2,
                  overflow: isExpandable ? null : TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isEditable && onEdit != null) ...[
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onEdit();
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: Color(0xFFDA6666),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildModernSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFFDA6666).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red[400] : const Color(0xFFDA6666),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDestructive ? Colors.red[400] : const Color(0xFF2C2C2C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getAccountTypeColor() {
    if (_isGuest) {
      return const Color(0xFFFFF3CD); // Light yellow for guest
    }
    
    final email = _profile?.email ?? '';
    if (email.contains('@gmail.com') || email.contains('google')) {
      return const Color(0xFFE3F2FD); // Light blue for Google
    }
    
    return const Color(0xFFF3E5F5); // Light purple for other accounts
  }
  
  IconData _getAccountTypeIcon() {
    if (_isGuest) {
      return Icons.person_outline;
    }
    
    final email = _profile?.email ?? '';
    if (email.contains('@gmail.com') || email.contains('google')) {
      return Icons.g_mobiledata; // Simple G for Google
    }
    
    return Icons.email_outlined;
  }
  
  String _getAccountTypeText() {
    if (_isGuest) {
      return 'Guest Account';
    }
    
    final email = _profile?.email ?? '';
    if (email.contains('@gmail.com') || email.contains('google')) {
      return 'Google Account';
    }
    
    return 'Email Account';
  }
  
  Color _getAccountTypeTextColor() {
    if (_isGuest) {
      return const Color(0xFF856404); // Dark yellow
    }
    
    final email = _profile?.email ?? '';
    if (email.contains('@gmail.com') || email.contains('google')) {
      return const Color(0xFF1565C0); // Dark blue
    }
    
    return const Color(0xFF6A1B9A); // Dark purple
  }
  
  Widget _buildUpgradeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDA6666), Color(0xFFE57373)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upgrade Your Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Link your guest account to save your data and access all features',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _linkWithGoogle,
                  icon: Image.asset(
                    'lib/assets/google_logo/google_logo.png',
                    height: 20,
                    width: 20,
                  ),
                  label: const Text('Link Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _registerWithEmail,
                  child: const Text('Register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Future<void> _linkWithGoogle() async {
    // Implement Google account linking
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/auth');
  }
  
  Future<void> _registerWithEmail() async {
    // Navigate to auth screen for registration
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/auth');
  }
  
  void _editBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _profile?.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFDA6666),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2C2C2C),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _profile?.dateOfBirth) {
      setState(() {
        _profile = _profile?.copyWith(dateOfBirth: picked);
      });
      
      // Save to Firebase
      if (_profile != null) {
        await _userService.saveUserProfile(_profile!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Birthday updated successfully'),
            backgroundColor: Color(0xFFDA6666),
          ),
        );
      }
    }
  }
  
  void _editBio() {
    final TextEditingController bioController = TextEditingController(text: _profile?.bio);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Edit Bio'),
        content: TextField(
          controller: bioController,
          maxLines: 4,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'Tell us about yourself...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFFDA6666)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              if (bioController.text != _profile?.bio) {
                setState(() {
                  _profile = _profile?.copyWith(bio: bioController.text);
                });
                
                // Save to Firebase
                if (_profile != null) {
                  await _userService.saveUserProfile(_profile!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bio updated successfully'),
                      backgroundColor: Color(0xFFDA6666),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFDA6666)),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE69C)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Beta Feature: These settings are currently in development and may not work as expected.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications on your device'),
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFFDA6666),
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive updates via email'),
              value: false,
              onChanged: (value) {},
              activeColor: const Color(0xFFDA6666),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE69C)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Beta Feature: These settings are currently in development and may not work as expected.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Private Profile'),
              subtitle: const Text('Only approved users can see your content'),
              value: false,
              onChanged: (value) {},
              activeColor: const Color(0xFFDA6666),
            ),
            SwitchListTile(
              title: const Text('Show Activity Status'),
              subtitle: const Text('Let others see when you\'re online'),
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFFDA6666),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Help & Support',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'better@onkaryaglewad.in',
                  query: 'subject=Better App Support',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
              child: const Text(
                'better@onkaryaglewad.in',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A90E2),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF5C6C6),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'lib/assets/better_navlogo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Better',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.2',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A memoir and journaling app designed to help you capture and cherish your life moments.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              '© 2025 Better App',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
