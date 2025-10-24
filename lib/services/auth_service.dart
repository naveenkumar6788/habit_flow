import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> authChanges() => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> registerWithEmail(String email, String password) async {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      return _auth.signInWithPopup(googleProvider);
    } else {
      // For non-web platforms in this demo, Google Sign-In is not configured.
      // You can add platform-specific configuration later if needed.
      throw FirebaseAuthException(code: 'unsupported', message: 'Google sign-in is supported on web only in this build');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
