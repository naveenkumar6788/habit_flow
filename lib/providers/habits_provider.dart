import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:paceai/models/habit.dart';
import 'package:paceai/models/habit_entry.dart';
import 'package:paceai/services/firebase_service.dart';

class HabitsProvider extends ChangeNotifier {
  String? _userId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _habitsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _entriesSub;
  List<Habit> habits = [];
  List<HabitEntry> entries = [];

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listen();
  }

  void _listen() {
    _habitsSub?.cancel();
    _entriesSub?.cancel();
    habits = [];
    entries = [];
    if (_userId == null) {
      notifyListeners();
      return;
    }
    _habitsSub = FirebaseService.habitsCol()
        .where('ownerId', isEqualTo: _userId)
        .where('archived', isEqualTo: false)
        .snapshots()
        .listen((query) {
      habits = query.docs.map((d) => Habit.fromMap(d.id, d.data())).toList();
      notifyListeners();
    });
    _entriesSub = FirebaseService.habitEntriesCol()
        .where('ownerId', isEqualTo: _userId)
        .snapshots()
        .listen((query) {
      entries = query.docs.map((d) => HabitEntry.fromMap(d.id, d.data())).toList();
      notifyListeners();
    });
  }

  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());

  Future<void> addHabit(String title, String? description) async {
    if (_userId == null) return;
    final id = const Uuid().v4();
    final habit = Habit(id: id, ownerId: _userId!, title: title, description: description);
    await FirebaseService.habitsCol().doc(id).set(habit.toMap());
  }

  Future<void> toggleToday(String habitId) async {
    if (_userId == null) return;
    final key = _todayKey();
    final existing = entries.firstWhere(
      (e) => e.habitId == habitId && e.dayKey == key,
      orElse: () => HabitEntry(id: '', habitId: habitId, ownerId: _userId!, dayKey: key, completed: false),
    );
    final id = existing.id.isEmpty ? const Uuid().v4() : existing.id;
    final newVal = !(existing.completed);
    final entry = HabitEntry(id: id, habitId: habitId, ownerId: _userId!, dayKey: key, completed: newVal);
    await FirebaseService.habitEntriesCol().doc(id).set(entry.toMap());
    // Award points when completing a habit for today
    if (newVal) {
      await FirebaseService.usersCol().doc(_userId).set({'points': FieldValue.increment(5)}, SetOptions(merge: true));
    }
  }

  int completionsForLastNDays(String habitId, int days) {
    final now = DateTime.now().toUtc();
    final keys = List.generate(days, (i) => DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i))));
    return entries.where((e) => e.habitId == habitId && keys.contains(e.dayKey) && e.completed).length;
  }

  @override
  void dispose() {
    _habitsSub?.cancel();
    _entriesSub?.cancel();
    super.dispose();
  }
}
