import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _userNameKey = 'user_name';
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
}
