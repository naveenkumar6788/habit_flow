import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:paceai/models/event.dart';
import 'package:paceai/services/firebase_service.dart';

class EventsProvider extends ChangeNotifier {
  String? _userId;
  List<EventModel> events = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    events = [];
    if (_userId == null) {
      notifyListeners();
      return;
    }
    _sub = FirebaseService.eventsCol()
        .orderBy('dateTime', descending: false)
        .limit(100)
        .snapshots()
        .listen((query) {
      events = query.docs.map((d) => EventModel.fromMap(d.id, d.data())).toList();
      notifyListeners();
    });
  }

  Future<void> createEvent(String title, String description, DateTime dateTime) async {
    if (_userId == null) return;
    final id = const Uuid().v4();
    final e = EventModel(id: id, title: title, description: description, dateTime: dateTime.toUtc(), createdBy: _userId!);
    await FirebaseService.eventsCol().doc(id).set(e.toMap());
  }

  Future<void> toggleRsvp(String eventId) async {
    if (_userId == null) return;
    final doc = FirebaseService.eventsCol().doc(eventId);
    await FirebaseService.db.runTransaction((txn) async {
      final snap = await txn.get(doc);
      final data = snap.data();
      if (data == null) return;
      final rsvps = (data['rsvps'] as List?)?.cast<String>() ?? <String>[];
      if (rsvps.contains(_userId)) {
        rsvps.remove(_userId);
      } else {
        rsvps.add(_userId!);
        // points +1
        txn.set(FirebaseService.usersCol().doc(_userId), {'points': FieldValue.increment(1)}, SetOptions(merge: true));
        // notify event creator
        final ownerId = data['createdBy'] as String?;
        if (ownerId != null && ownerId != _userId) {
          final notifId = const Uuid().v4();
          txn.set(FirebaseService.notificationsCol().doc(notifId), {
            'userId': ownerId,
            'type': 'rsvp',
            'message': 'Someone RSVPed to your event',
            'refId': eventId,
            'read': false,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }
      txn.update(doc, {'rsvps': rsvps});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
