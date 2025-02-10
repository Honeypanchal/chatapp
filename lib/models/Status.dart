import 'package:cloud_firestore/cloud_firestore.dart';

class Status {
  final String uid;
  final String userId;
  final String username;
  final String text;
  final String backgroundColor;
  final String textStyle;
  final Timestamp timestamp;
  final List<String> viewedBy;
  final List<Map<String, String>> statusReplies;
  final bool isViewed;

  Status({
    required this.uid,
    required this.userId,
    required this.username,
    required this.text,
    required this.backgroundColor,
    required this.textStyle,
    required this.timestamp,
    required this.viewedBy,
    this.statusReplies= const[],
    this.isViewed = false,
    });
  factory Status.fromMap(Map<String, dynamic> data) {

    return Status(
      uid: data['uid'] ?? "",
      userId: data['userId']?? "" ,
      username: data['username'] ?? "Unknown",
      text: data['text'] ?? "",
      backgroundColor: data['backgroundColor'] ?? "#FFFFFF",
      textStyle: data['textStyle'] ?? "0",
      timestamp: data['timestamp'] is Timestamp ? data['timestamp'] as Timestamp : Timestamp.now(),
      viewedBy: List<String>.from(data['viewedBy'] ?? []),

      statusReplies: (data['statusReplies'] as List<dynamic>?)?.map((item) {
        return {
          'replyBy': item is Map<String, dynamic> && item.containsKey('replyBy') ? item['replyBy'].toString() : "Unknown",
          'replyText': item is Map<String, dynamic> && item.containsKey('replyText') ? item['replyText'].toString() : "",
          'timestamp': item is Map<String, dynamic> && item.containsKey('timestamp') && item['timestamp'] is Timestamp
              ? (item['timestamp'] as Timestamp).toDate().toString()
              : "Unknown Time"
        };
      }).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userId':userId,
      'username': username,
      'text': text,
      'backgroundColor': backgroundColor,
      'textStyle': textStyle,
      'timestamp': timestamp,
      'viewedBy': viewedBy,
      'statusReplies': statusReplies,
    };
  }

  Status copyWith({bool? isViewed}) {
    return Status(
      uid: uid,
      userId: userId,
      username: username,
      text: text,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
      timestamp: timestamp,
      viewedBy: viewedBy,
      statusReplies: statusReplies,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}