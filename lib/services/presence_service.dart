import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _presenceRef(String roomId) {
    return _firestore.collection('rooms').doc(roomId).collection('presence');
  }

  Future<void> updatePresence(String roomId, String userId) async {
    await _presenceRef(roomId).doc(userId).set({
      'userId': userId,
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    await _presenceRef(roomId).doc(userId).delete();
  }

  Stream<int> getActiveMemberCount(String roomId) {
    return _presenceRef(roomId).snapshots().map((snapshot) {
      final now = DateTime.now();
      int activeCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data['lastSeenAt'] == null) {
          activeCount++;
          continue;
        }

        final Timestamp? ts = data['lastSeenAt'] as Timestamp?;
        if (ts != null) {
          final lastSeen = ts.toDate();
          if (now.difference(lastSeen).inMinutes < 2) {
            activeCount++;
          }
        }
      }
      return activeCount;
    });
  }
}
