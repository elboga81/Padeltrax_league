import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  late final FirebaseFirestore firestore;
  late final FirebaseAuth auth;
  bool _initialized = false;

  // Private constructor
  FirebaseService._();

  static FirebaseService get instance => _instance;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firestore and Auth instances
      firestore = FirebaseFirestore.instance;
      auth = FirebaseAuth.instance;

      // Configure Firestore settings
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _initialized = true;
      debugPrint('Firebase Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase Service: $e');
      throw Exception('Failed to initialize Firebase Service: $e');
    }
  }

  // Get default instance of FirebaseFirestore
  static FirebaseFirestore get firestoreInstance {
    if (!_instance._initialized) {
      throw StateError('FirebaseService must be initialized first');
    }
    return _instance.firestore;
  }

  // Get default instance of FirebaseAuth
  static FirebaseAuth get authInstance {
    if (!_instance._initialized) {
      throw StateError('FirebaseService must be initialized first');
    }
    return _instance.auth;
  }

  // Helper method to check if user is signed in
  bool get isUserSignedIn => auth.currentUser != null;

  // Get current user
  User? get currentUser => auth.currentUser;

  // Sign out helper
  Future<void> signOut() async {
    if (!_initialized) {
      throw StateError('FirebaseService must be initialized first');
    }
    await auth.signOut();
  }

  // Get a Firestore document reference
  DocumentReference document(String path) {
    if (!_initialized) {
      throw StateError('FirebaseService must be initialized first');
    }
    return firestore.doc(path);
  }

  // Get a Firestore collection reference
  CollectionReference collection(String path) {
    if (!_initialized) {
      throw StateError('FirebaseService must be initialized first');
    }
    return firestore.collection(path);
  }

  // Handle any cleanup if needed
  Future<void> dispose() async {
    // Add any cleanup code here
    _initialized = false;
  }

  // Helper method to reset instance (useful for testing)
  @visibleForTesting
  static void reset() {
    _instance._initialized = false;
  }

  bool get isInitialized => _initialized;
}
