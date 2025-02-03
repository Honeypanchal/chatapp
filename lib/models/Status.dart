import 'package:cloud_firestore/cloud_firestore.dart';

class Status {
  String uid;
  String username;
  String text;
  String backgroundColor;
  String textStyle;
  Timestamp timestamp;
  List<String> viewedBy;

  Status({
    required this.uid,
    required this.username,
    required this.text,
    required this.backgroundColor,
    required this.textStyle,
    required this.timestamp,
    required this.viewedBy,
  });



  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'],
      username: map['username'],
      text: map['text'] ?? "",
      backgroundColor: map['backgroundColor'] ?? "#FFFFFF",
      textStyle: map['textStyle'] ?? '20',
      timestamp: map['timestamp'],
      viewedBy: List<String>.from(map['viewedBy'] ?? []),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'text': text,
      'backgroundColor':backgroundColor,
      'textStyle':textStyle,
      'timestamp': timestamp,
      'viewedBy': viewedBy,
    };
  }
}
