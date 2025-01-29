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

  Group newGroup=Group(
      groupName: groupName,
      groupIcon: groupIcon,
      groupDescription: groupDescription,
      createdBy: createdBy,
      participants: participants,
      createdAt: createdAt);
  //
  // final newGroupId =  groupsDb.add( newGroup.toMap() );
  // print(newGroupId);
  DocumentReference docRef = await groupsDb.add(newGroup.toMap()); // Await Firestore add operation
  String groupId = docRef.id;
  print(groupId);// Get the generated document ID
  return newGroup;
}
