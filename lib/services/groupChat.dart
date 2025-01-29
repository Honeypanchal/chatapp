import 'package:chatapp/models/CustomClass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/Group.dart';

CollectionReference groupsDb = FirebaseFirestore.instance.collection("groups");

Future<Group> createNewGroup(
    String groupName,
    String groupIcon,
    String groupDescription,
    String createdBy,
    List<String> participants,
    Timestamp createdAt) async {
  Group newGroup = Group(
    groupId: '',
    groupName: 'My Group',
    groupIcon: 'icon_url',
    groupDescription: 'This is a group.',
    createdBy: 'User1',
    participants: ['User1', 'User2'],
    createdAt: Timestamp.now(),
  );

  final newGroupRef = await groupsDb.add(newGroup.toMap());
  String newGroupId = newGroupRef.id;
  newGroup.addId(newGroupId);


  return newGroup;
}