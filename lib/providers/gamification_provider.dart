import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paceai/services/firebase_service.dart';

class GamificationProvider extends ChangeNotifier {
  String? _userId;
  int points = 0;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listen();
  }

  void _listen() {
    _userSub?.cancel();
    points = 0;
    if (_userId == null) {
      notifyListeners();
      return;
    }
    _userSub = FirebaseService.usersCol().doc(_userId).snapshots().listen((snap) {
      final data = snap.data();
      points = (data?['points'] ?? 0) as int;
      notifyListeners();
    });
  }

  Future<void> addPoints(int delta) async {
    if (_userId == null) return;
    await FirebaseService.usersCol().doc(_userId).set({
      'points': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}
