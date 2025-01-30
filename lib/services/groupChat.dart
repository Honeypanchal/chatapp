import 'package:chatapp/models/CustomClass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/Group.dart';

CollectionReference groupsDb = FirebaseFirestore.instance.collection("groups");

Future<Group?> createNewGroup(
    String groupName,
    String groupIcon,
    String groupDescription,
    String createdBy,
    List<String> participants,
    bool groupSettings,
    bool sendMessages,
    bool addOtherMembers) async {
  try {
    if (groupName.isEmpty) {
      throw Exception(" Group name cannot be empty. ");
    }

    if (participants.isEmpty) {
      throw Exception("A group must have at least one participant.");
    }

    Group newGroup = Group(
      groupId: '',
      groupName: groupName,
      groupIcon: groupIcon,
      groupDescription: groupDescription,
      createdBy: createdBy,
      participants: participants,
      createdAt: Timestamp.now(),
      groupSettings: groupSettings,
      sendMessages: sendMessages,
      addOtherMembers: addOtherMembers,
    );
    final newGroupRef = await groupsDb.add(newGroup.toMap());
    String newGroupId = newGroupRef.id;
    newGroup.addId(newGroupId);
    print(" Group created successfully with ID: $newGroupId ");
    return newGroup;
  } on FirebaseException catch (e) {
    print(" Firestore error: ${e.message} ");
    return null;
  } on Exception catch (e) {
    print(" Error: $e ");
    return null;
  }
}
