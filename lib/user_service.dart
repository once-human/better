import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_profile.dart';

class UserService {
  static const String _userNameKey = 'user_name';
  static const String _profileCompleteKey = 'profile_complete';
  static const String _profileDataKey = 'profile_data';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store user data after successful login
  Future<void> storeUserData(String name, String email, String? photoUrl) async {
    print('UserService DEBUG: Starting storeUserData for: $name');
    try {
      User? user = _auth.currentUser;
      print('UserService DEBUG: Current user UID: ${user?.uid}');
      
      if (user != null) {
        // Store in Firestore
        print('UserService DEBUG: Attempting to store in Firestore...');
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'photoUrl': photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('UserService DEBUG: Firestore storage successful');

        // Also store in local preferences for quick access
        print('UserService DEBUG: Storing in SharedPreferences...');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userNameKey, name);
        print('UserService DEBUG: SharedPreferences storage successful');
      } else {
        print('UserService DEBUG: No current user found!');
      }
    } catch (e) {
      print('UserService DEBUG: Error storing user data: $e');
      print('UserService DEBUG: Falling back to local storage only');
      // Fallback to local storage only
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userNameKey, name);
        print('UserService DEBUG: Fallback storage successful');
      } catch (localError) {
        print('UserService DEBUG: Fallback storage failed: $localError');
      }
    }
    print('UserService DEBUG: storeUserData completed');
  }

  // Get stored user name
  Future<String?> getUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Try to get from Firestore first
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['name'] as String?;
        }
      }

      // Fallback to local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      print('Error getting user name: $e');
      // Fallback to local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    }
  }

  // Clear user data (for logout)
  Future<void> clearUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userNameKey);
      await prefs.remove(_profileCompleteKey);
      print('UserService DEBUG: User data cleared');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }

  // Mark profile as complete
  Future<void> markProfileComplete() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_profileCompleteKey, true);
      print('UserService DEBUG: Profile marked as complete');
    } catch (e) {
      print('UserService DEBUG: Error marking profile complete: $e');
    }
  }

  // Check if profile is complete
  Future<bool> isProfileComplete() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isComplete = prefs.getBool(_profileCompleteKey) ?? false;
      print('UserService DEBUG: Profile complete check: $isComplete');
      return isComplete;
    } catch (e) {
      print('UserService DEBUG: Error checking profile complete: $e');
      return false;
    }
  }

  // Save complete user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      // Store in Firestore (non-blocking)
      _firestore.collection('users').doc(user.uid).set(
        profile.toMap(),
        SetOptions(merge: true),
      ).catchError((error) {
        print('UserService DEBUG: Firestore save failed: $error');
      });
      
      // Store locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileDataKey, jsonEncode(profile.toMap()));
      await prefs.setString(_userNameKey, profile.fullName);
      await prefs.setBool(_profileCompleteKey, true);
      
      print('UserService DEBUG: Profile saved successfully');
    } catch (e) {
      print('UserService DEBUG: Error saving profile: $e');
      throw e;
    }
  }

  // Get full user profile
  Future<UserProfile?> getUserFullProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;
      
      // Try to get from local storage first
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? profileJson = prefs.getString(_profileDataKey);
      
      if (profileJson != null) {
        return UserProfile.fromMap(jsonDecode(profileJson));
      }
      
      // Fallback to Firestore
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 5));
            
        if (doc.exists && doc.data() != null) {
          final profile = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
          // Cache locally
          await prefs.setString(_profileDataKey, jsonEncode(profile.toMap()));
          return profile;
        }
      } catch (firestoreError) {
        print('UserService DEBUG: Firestore read failed: $firestoreError');
      }
      
      return null;
    } catch (e) {
      print('UserService DEBUG: Error getting full profile: $e');
      return null;
    }
  }

  // Check if user needs to complete profile
  Future<bool> needsProfileCompletion() async {
    User? user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      // First check Firestore for existing profile
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 3));
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        // If profile exists in Firestore and is complete, no need for completion
        if (data['isComplete'] == true) {
          // Cache locally for future checks
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_profileCompleteKey, true);
          await prefs.setString(_profileDataKey, jsonEncode(data));
          return false;
        }
      }
    } catch (e) {
      print('UserService DEBUG: Firestore check failed, checking local: $e');
    }
    
    // Check local storage as fallback
    bool isComplete = await isProfileComplete();
    if (isComplete) return false;
    
    // For anonymous users, always need profile if not complete
    if (user.isAnonymous) return true;
    
    // For email/Google users, check if we have full profile data
    UserProfile? profile = await getUserFullProfile();
    return profile == null || !profile.isComplete;
  }
}
