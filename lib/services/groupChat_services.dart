import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/services/users_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/Group.dart';

CollectionReference groupsDb = FirebaseFirestore.instance.collection("groups");

Future<Group?> createNewGroup(String groupName,
    String groupIcon,
    String groupDescription,
    String createdBy,
    List<String> participants,
    List<String> admins,
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
      groupName: groupName.toLowerCase(),
      groupIcon: groupIcon,
      groupDescription: groupDescription,
      createdBy: createdBy,
      participants: participants,
      admins: admins,
      createdAt: Timestamp.now(),
      groupSettings: groupSettings,
      sendMessages: sendMessages,
      addOtherMembers: addOtherMembers,
    );
    final newGroupRef = await groupsDb.add(newGroup.toMap());
    String newGroupId = newGroupRef.id;
    await groupsDb.doc(newGroupId).update({"groupId": newGroupId});
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

Future<dynamic> fetchGroupByGroupId(String groupId) async {
  try {
    print("HEREKHNFSEHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH");
    final group = await groupsDb.doc(groupId).get();

    print(groupId);
    return group;
  } catch (e) {
    throw e;
  }
}

Future<void> editGroupInfo(String groupId, String desc) async {
  try {
    print('$groupId');
    final data = await groupsDb.doc(groupId).update({"groupDescription": desc});
    print("Edited succesfully");
  } catch (e) {
    rethrow;
  }
}
Future<void> editGroupName(String groupId,String name) async{
  try {
    print('$groupId');
    final data = await groupsDb.doc(groupId).update({"groupName": name});
    print("Edited succesfully");
  } catch (e) {
    rethrow;
  }
}

Future<void> updateGroupSettings(String groupId, bool groupSettings,
    bool sendMessages, bool addOtherMembers,List<String> admins) async{
  try {
    final groupDoc = await groupsDb.doc(groupId).update({
      "groupSettings":groupSettings,
      "sendMessages":sendMessages,
      "addOtherMembers":addOtherMembers,
      "admins":admins,
    });
  } catch (e) {
    print(e.toString());
  }
}
Future<void> addNewMembersToGroup(String groupId, List<String> newMembers)async{
  try{
    final  foundGroup=groupsDb.doc(groupId);
   await  foundGroup.update({"participants":FieldValue.arrayUnion(newMembers)});

  }catch(e){
    print(e.toString());

  }finally{
   print("New member added succesfully!");
  }}
Future<void> removeUserFromGroupParticipants(String groupId, String userId) async {
  final groupDoc = await groupsDb.doc(groupId).get();

  if (!groupDoc.exists) return;

  try {
    final groupData = groupDoc.data() as Map<String, dynamic>;
    List<String> participants = List.from(groupData['participants']);
    List<String> admins = List.from(groupData['admins']);

    if (participants.contains(userId)) {
      participants.remove(userId);
    }
    if (admins.contains(userId)) {
      admins.remove(userId);
    }

    print("${admins.length} is length of admins list");
    if (participants.isEmpty) {
      print("No participants left, deleting group...");
      await groupsDb.doc(groupId).delete();
      return;
    }
    if (admins.isEmpty && participants.isNotEmpty) {
      print("Assigning first participant as the new admin");
      admins.add(participants.first);
      makeUserAdminOfThisGroup(groupId,participants.first);
    }



    await groupsDb.doc(groupId).update({
      'participants': participants,
      'admins': admins,
    });

    print("User $userId removed successfully from the group.");
  } catch (e) {
    rethrow;
  }
}


Future<void> removeUserFromThisGroup(String groupId, String userId)async{
  try{
    print("here in group chat  services");
    final groupDbRef=  groupsDb.doc(groupId);
    final groupDb= await groupDbRef.get();
    List<String> participants = List.from(groupDb['participants']);
    List<String> admins=List.from(groupDb['admins']);
    if(admins.contains(userId)){
      print("user also removed from admin");
      admins.removeWhere((user)=>user==userId);
    }
    participants.removeWhere((user)=>user==userId);
    groupDbRef.update({"participants":participants,"admins":admins});
    print("User ${userId} removed from group succesfully!");
  }catch(e){
    print(e.toString());
  }
}