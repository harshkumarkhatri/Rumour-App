import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final String senderHandle;
  final String displayName;
  final bool isMe;
  final DateTime timestamp;

  final DocumentSnapshot? sourceDoc;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderHandle,
    required this.displayName,
    required this.timestamp,
    this.isMe = false,
    this.sourceDoc,
  });

  factory Message.fromFirestore(DocumentSnapshot doc, String currentUserId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderHandle: data['senderHandle'] ?? 'Anonymous',
      displayName: data['displayName'] ?? data['senderHandle'] ?? 'Anonymous',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isMe: (data['senderId'] == currentUserId),
      sourceDoc: doc,
    );
  }
}
