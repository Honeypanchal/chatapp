import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String groupId;
  final String groupName;
  final String groupIcon;
  final String groupDescription;
  final String createdBy;
  final List<String> participants;
  final Timestamp createdAt;

  Group({
    required this.groupId,
    required this.groupName,
    required this.groupIcon,
    required this.groupDescription,
    required this.createdBy,
    required this.participants,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupIcon': groupIcon,
      'groupDescription': groupDescription,
      'createdBy': createdBy,
      'participants': participants,
      'createdAt': createdAt,
    };
  }


  Group getGroupDetails(DocumentSnapshot doc) {
    return Group(
      groupId: doc.id,
      groupName: doc['groupName'],
      groupIcon: doc['groupIcon'],
      groupDescription: doc['groupDescription'],
      createdBy: doc['createdBy'],
      participants: List<String>.from(doc['participants']),
      createdAt: doc['createdAt'],
    );
  }
}
