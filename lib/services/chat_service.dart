import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import 'identity_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IdentityService _identityService = IdentityService();

  CollectionReference _messagesRef(String roomId) {
    return _firestore.collection('rooms').doc(roomId).collection('messages');
  }

  Stream<List<Message>> getMessagesStream(
    String roomId,
    String currentUserId, {
    int limit = 25,
  }) {
    return _messagesRef(roomId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Message.fromFirestore(doc, currentUserId);
          }).toList();
        });
  }

  Future<List<Message>> getHistory(
    String roomId,
    String currentUserId,
    DocumentSnapshot startAfterDoc, {
    int limit = 25,
  }) async {
    try {
      final snapshot = await _messagesRef(roomId)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(startAfterDoc)
          .limit(limit)
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs
          .map((doc) => Message.fromFirestore(doc, currentUserId))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> sendMessage(String roomId, String text) async {
    final identity = await _identityService.getIdentityForRoom(roomId);

    await _messagesRef(roomId).add({
      'text': text,
      'senderId': identity.handle,
      'senderHandle': identity.handle,
      'displayName': identity.displayName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
