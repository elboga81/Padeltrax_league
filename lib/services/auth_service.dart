import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart'; // Importing the centralized FirebaseService

class AuthService {
  late final FirebaseAuth _auth;

  AuthService() {
    _auth = FirebaseService.instance.auth; // Use centralized service
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    final lowercaseEmail = email.trim().toLowerCase();
    try {
      debugPrint('Registering user with email: $lowercaseEmail');
      return await _auth.createUserWithEmailAndPassword(
        email: lowercaseEmail,
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e, action: 'Registration');
    } catch (e) {
      debugPrint('Exception during registration: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    final lowercaseEmail = email.trim().toLowerCase();
    try {
      debugPrint('Attempting login for email: $lowercaseEmail');
      return await _auth.signInWithEmailAndPassword(
        email: lowercaseEmail,
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e, action: 'Login');
    } catch (e) {
      debugPrint('Exception during login: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Sign-out failed: $e');
      throw Exception('Sign-out failed: $e');
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Get current user object
  User? get currentUser => _auth.currentUser;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Private helper for FirebaseAuthException handling
  Exception _handleAuthException(FirebaseAuthException e,
      {required String action}) {
    switch (e.code) {
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'email-already-in-use':
        return Exception('This email is already registered.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'operation-not-allowed':
        return Exception(
            'Email/password accounts are not enabled. Please contact support.');
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      default:
        return Exception('$action failed: ${e.message}');
    }
  }
}
