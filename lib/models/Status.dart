import 'package:cloud_firestore/cloud_firestore.dart';

class Status
{
  String uid;
  String username;
  String photoUrl;
  List<String> statusImageUrls;
  Timestamp timestamp;
  List<String> viewBy;

  Status({
    required this.uid,
    required this.username,
    required this.photoUrl,
    required this.statusImageUrls,
    required this.timestamp,
    required this.viewBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'photoUrl': photoUrl,
      'statusImageUrls': statusImageUrls,
      'timestamp': timestamp,
      'viewedBy': viewBy,
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'],
      username: map['username'],
      photoUrl: map['photoUrl'],
      statusImageUrls: List<String>.from(map['statusImageUrls']),
      timestamp: map['timestamp'],
      viewBy: List<String>.from(map['viewedBy']),
    );
  }
}
