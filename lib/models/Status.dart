import 'package:cloud_firestore/cloud_firestore.dart';

class Status {
  String uid;
  String username;
  String text;
  Timestamp timestamp;
  List<String> viewedBy;

  Status({
    required this.uid,
    required this.username,
    required this.text,
    required this.timestamp,
    required this.viewedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'text': text,
      'timestamp': timestamp,
      'viewedBy': viewedBy,
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'],
      username: map['username'],
      text: map['text'] ?? "",
      timestamp: map['timestamp'],
      viewedBy: List<String>.from(map['viewedBy'] ?? []),
    );
  }
}
