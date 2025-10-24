import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:paceai/models/post.dart';
import 'package:paceai/models/comment.dart';
import 'package:paceai/services/firebase_service.dart';

class FeedProvider extends ChangeNotifier {
  String? _userId;
  List<Post> posts = [];
  Map<String, List<CommentModel>> comments = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _postsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _commentsSub;

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listen();
  }

  void _listen() {
    _postsSub?.cancel();
    _commentsSub?.cancel();
    posts = [];
    comments = {};
    if (_userId == null) {
      notifyListeners();
      return;
    }
    _postsSub = FirebaseService.postsCol()
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((query) {
      posts = query.docs.map((d) => Post.fromMap(d.id, d.data())).toList();
      notifyListeners();
    });
    _commentsSub = FirebaseService.commentsCol()
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .listen((query) {
      final list = query.docs.map((d) => CommentModel.fromMap(d.id, d.data())).toList();
      comments = {};
      for (final c in list) {
        comments.putIfAbsent(c.postId, () => []).add(c);
      }
      notifyListeners();
    });
  }

  Future<void> createPost(String content) async {
    if (_userId == null) return;
    final id = const Uuid().v4();
    final post = Post(id: id, userId: _userId!, content: content, createdAt: DateTime.now().toUtc());
    await FirebaseService.postsCol().doc(id).set(post.toMap());
    // points +2
    await FirebaseService.usersCol().doc(_userId).set({'points': FieldValue.increment(2)}, SetOptions(merge: true));
  }

  Future<void> toggleLike(String postId) async {
    if (_userId == null) return;
    final doc = FirebaseService.postsCol().doc(postId);
    await FirebaseService.db.runTransaction((txn) async {
      final snap = await txn.get(doc);
      final data = snap.data();
      if (data == null) return;
      final likes = (data['likes'] as List?)?.cast<String>() ?? <String>[];
      if (likes.contains(_userId)) {
        likes.remove(_userId);
      } else {
        likes.add(_userId!);
        // notify post owner
        final ownerId = data['userId'] as String?;
        if (ownerId != null && ownerId != _userId) {
          final notifId = const Uuid().v4();
          txn.set(FirebaseService.notificationsCol().doc(notifId), {
            'userId': ownerId,
            'type': 'like',
            'message': 'Someone liked your post',
            'refId': postId,
            'read': false,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }
      txn.update(doc, {'likes': likes});
    });
  }

  Future<void> addComment(String postId, String text) async {
    if (_userId == null) return;
    final id = const Uuid().v4();
    final c = CommentModel(id: id, postId: postId, userId: _userId!, text: text, createdAt: DateTime.now().toUtc());
    await FirebaseService.commentsCol().doc(id).set(c.toMap());
    // points +1
    await FirebaseService.usersCol().doc(_userId).set({'points': FieldValue.increment(1)}, SetOptions(merge: true));
    // notify post owner
    final postSnap = await FirebaseService.postsCol().doc(postId).get();
    final ownerId = postSnap.data()?['userId'] as String?;
    if (ownerId != null && ownerId != _userId) {
      final notifId = const Uuid().v4();
      await FirebaseService.notificationsCol().doc(notifId).set({
        'userId': ownerId,
        'type': 'comment',
        'message': 'Someone commented on your post',
        'refId': postId,
        'read': false,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  @override
  void dispose() {
    _postsSub?.cancel();
    _commentsSub?.cancel();
    super.dispose();
  }
}
