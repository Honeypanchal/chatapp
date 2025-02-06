import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String sentBy;
  final String sentTo;
  final Timestamp timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sentBy,
    required this.sentTo,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      text: map['message'] ?? '',
      sentBy: map['sentBy'] ?? '',
      sentTo: map['sentTo'] ?? '',
      timestamp: map['timestamp'],
    );
  }
}
