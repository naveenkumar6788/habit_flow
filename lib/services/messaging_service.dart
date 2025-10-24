import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> ensureInitializedAndRegisterToken(String userId) async {
    if (_initialized) return;
    _initialized = true;
    // Request permission (no-op on web if not supported)
    try {
      await _messaging.requestPermission();
    } catch (_) {}

    // Get token and save to user doc
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}

    // Listen foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Optionally handle in-app notifications here. For now, no-op.
      debugPrint('FCM onMessage: ${message.messageId}');
    });
  }
}
