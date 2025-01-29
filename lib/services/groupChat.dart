import 'package:chatapp/models/CustomClass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/Group.dart';

CollectionReference groupsDb = FirebaseFirestore.instance.collection("groups");

Future<Group> createNewGroup(
    String groupName,
    String groupIcon,
    String groupDescription,
    CustomClass createdBy,
    List<Map<String,dynamic>> participants) async {
  Group newGroup = Group(
    groupId: '',
    groupName: groupName,
    groupIcon: groupIcon,
    groupDescription:groupDescription,
    createdBy: createdBy.toMap(),
    participants: participants,
    createdAt: Timestamp.now(),
  );

  final newGroupRef = await groupsDb.add(newGroup.toMap());
  String newGroupId = newGroupRef.id;
  newGroup.addId(newGroupId);


  return newGroup;
}