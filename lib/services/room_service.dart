import 'dart:math' hide log;
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class RoomService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference get _rooms => _firestore.collection('rooms');

  Future<String> joinOrCreateRoom(String roomCode) async {
    try {
      final cacheQuery = await _rooms
          .where('code', isEqualTo: roomCode)
          .limit(1)
          .get(const GetOptions(source: Source.cache));

      if (cacheQuery.docs.isNotEmpty) {
        _rooms
            .doc(cacheQuery.docs.first.id)
            .update({'lastActive': FieldValue.serverTimestamp()})
            .catchError((_) {});

        return cacheQuery.docs.first.id;
      }

      final snapshot = await _rooms
          .where('code', isEqualTo: roomCode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        await doc.reference.update({
          'lastActive': FieldValue.serverTimestamp(),
        });
        return doc.id;
      } else {
        final docRef = await _rooms.add({
          'code': roomCode,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        });
        return docRef.id;
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to join or create room: $e');
    }
  }

  Future<Map<String, String>> createRoom() async {
    int attempts = 0;
    final random = Random();
    while (attempts < 5) {
      final code = (100000 + random.nextInt(900000)).toString();

      final snapshot = await _rooms
          .where('code', isEqualTo: code)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        final docRef = await _rooms.add({
          'code': code,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        });
        return {'id': docRef.id, 'code': code};
      }
      attempts++;
    }
    throw Exception("Failed to generate a unique room code after 5 attempts");
  }
}


class IdentityService {
  static const String _kUserIdKey = 'user_id';
  static const String _kUserNameKey = 'user_name';

  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_kUserIdKey);
    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString(_kUserIdKey, userId);
    }
    return userId;
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserNameKey);
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserNameKey, name);
  }

  Future<bool> hasIdentity() async {
    final name = await getUserName();
    return name != null && name.isNotEmpty;
  }
}
