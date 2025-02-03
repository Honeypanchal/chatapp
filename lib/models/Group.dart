import 'package:chatapp/models/CustomClass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
      String? groupId;
  final String groupName;
  final String groupIcon;
  final String groupDescription;
  final String createdBy;
  final List<String?> admins;
  final List<String?> participants;
  final Timestamp createdAt;
  final bool groupSettings;
  final bool sendMessages;
  final bool addOtherMembers;

  Group({
    required this.groupName,
    required this.groupIcon,
    required this.groupDescription,
    required this.createdBy,
    required this.admins,
    required this.participants,
    required this.createdAt,
    this.groupSettings=true,
    this.sendMessages=true,
    this.addOtherMembers=true,
required this.groupId,


  });

  Map<String, dynamic> toMap() {
    return {
'groupId':groupId,
      'groupName': groupName,
      'groupIcon': groupIcon,
      'groupDescription': groupDescription,
      'createdBy': createdBy,
      'admins':admins
      ,
      'participants': participants,
      'createdAt': createdAt,
      'groupSettings':groupSettings,
      "sendMessages":sendMessages,
      "addOtherMembers":addOtherMembers,
    };
  }
void addId(String id )
{
  this.groupId=id;

}

  Group getGroupDetails(DocumentSnapshot doc) {
    return Group(

      groupName: doc['groupName'],
      groupIcon: doc['groupIcon'],
      groupDescription: doc['groupDescription'],
      createdBy:  doc['createdBy'],
      participants: List<String>.from(doc['participants']),
      admins: List<String>.from(doc['admins']),
      createdAt: doc['createdAt'],
      groupSettings: doc['groupSettings'],
      sendMessages: doc['sendMessages'],
      addOtherMembers: doc['addOtherMembers'],
      groupId: doc['groupId']
    );
  }
}
