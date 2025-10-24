import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paceai/models/user_profile.dart';
import 'package:paceai/services/auth_service.dart';
import 'package:paceai/services/firebase_service.dart';
import 'package:paceai/services/messaging_service.dart';

class AuthProvider extends ChangeNotifier {
  String? userId;
  UserProfile? profile;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  bool _initialized = false;

  bool get initialized => _initialized;

  AuthProvider() {
    _authSub = AuthService.authChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    // Update local state immediately and notify so UI can react to login/logout
    userId = user?.uid;
    _profileSub?.cancel();
    profile = null;
    notifyListeners();

    if (user != null) {
      final docRef = FirebaseService.usersCol().doc(user.uid);
      // Ensure user doc exists without blocking auth state updates
      try {
        await docRef.set({
          // Prefer a displayName; fallback to email local-part
          'displayName': user.displayName ?? (user.email != null ? user.email!.split('@').first : null),
          'email': user.email,
          'photoUrl': user.photoURL,
          'points': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        // Avoid breaking auth flow if Firestore rules are restrictive
        debugPrint('User profile write failed: $e');
      }

      try {
        _profileSub = docRef.snapshots().listen((snap) {
          final data = snap.data();
          if (data != null) {
            profile = UserProfile.fromMap(snap.id, data);
            notifyListeners();
          }
        });
      } catch (e) {
        debugPrint('User profile subscription failed: $e');
      }

      // Register FCM token on login (no-op on unsupported platforms)
      try {
        await MessagingService.ensureInitializedAndRegisterToken(user.uid);
      } catch (e) {
        debugPrint('FCM registration failed: $e');
      }
    }

    // Mark auth stream as initialized after first emission
    if (!_initialized) {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> signInEmail(String email, String password) async {
    await AuthService.signInWithEmail(email, password);
  }

  Future<void> registerEmail(String email, String password) async {
    await AuthService.registerWithEmail(email, password);
  }

  Future<void> signInGoogle() async {
    await AuthService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await AuthService.signOut();
  }

  Future<void> updateDisplayName(String newName) async {
    final uid = userId;
    if (uid == null) return;
    try {
      await FirebaseService.usersCol().doc(uid).set({
        'displayName': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update displayName in Firestore: $e');
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
      }
    } catch (e) {
      debugPrint('Failed to update FirebaseAuth displayName: $e');
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
