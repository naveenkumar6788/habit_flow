import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paceai/models/app_notification.dart';
import 'package:paceai/services/firebase_service.dart';

class NotificationsProvider extends ChangeNotifier {
  String? _userId;
  List<AppNotification> notifications = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    notifications = [];
    if (_userId == null) {
      notifyListeners();
      return;
    }
    _sub = FirebaseService.notificationsCol()
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((query) {
      notifications = query.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList();
      notifyListeners();
    });
  }

  Future<void> markRead(String id) async {
    await FirebaseService.notificationsCol().doc(id).set({'read': true}, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
