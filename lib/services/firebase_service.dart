import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> usersCol() => db.collection('users');
  static CollectionReference<Map<String, dynamic>> habitsCol() => db.collection('habits');
  static CollectionReference<Map<String, dynamic>> habitEntriesCol() => db.collection('habit_entries');
  static CollectionReference<Map<String, dynamic>> postsCol() => db.collection('posts');
  static CollectionReference<Map<String, dynamic>> commentsCol() => db.collection('comments');
  static CollectionReference<Map<String, dynamic>> eventsCol() => db.collection('events');
  static CollectionReference<Map<String, dynamic>> notificationsCol() => db.collection('notifications');
}
