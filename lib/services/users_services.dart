import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final CollectionReference usersDb = FirebaseFirestore.instance.collection("Users");

Future<List<String>> getUserNames(List<String> usersUid) async {
  List<String> userNames = [];
print("here to fetch firstnames");
  for (String user in usersUid) {
    DocumentSnapshot snapshot = await usersDb.doc(user).get();
    if (snapshot.exists) {
      print('here');
      String firstName = snapshot.get("firstName") ?? "Unknown"; // Handle null values
      userNames.add(firstName);
    }
  }

  return userNames;
}
Future<void> addGroupAndAddActiveGroupInDatabase(
    String groupId, String path, bool isAdmin) async {
  try {
    DocumentReference userRef = usersDb.doc(path);
    DocumentSnapshot snapshot = await userRef.get();

    if (!snapshot.exists) {
      print("User document not found");
      return;
    }

    List<dynamic> groupList = snapshot.get("groups") ?? [];

    bool groupExists = groupList.any((group) => group["groupId"] == groupId);

    if (!groupExists) {
      print("Adding new group with admin status: $isAdmin");

      await userRef.update({
        "groups": FieldValue.arrayUnion([
          {"groupId": groupId, "admin": isAdmin}
        ])
      });

      print("Group added successfully");
    } else {
      print("Group already exists");
    }
  } catch (e) {
    print("Error: ${e.toString()}");
  }
}

Future<String> getFirstNameById(String userId)async{
  final userdata= await usersDb.doc(userId).get();

  return userdata['firstName'];
}

Future<String> getCurrentUser()async{
  final user = FirebaseAuth.instance.currentUser;
  print("Current user is ${user!.uid}");
  return user.uid;
}


Future<void> updateAdminStatusForCurrentUser(String userId, String groupId, bool isAdmin) async {
  print('${userId} is having status of $isAdmin');
  final user = usersDb.doc(userId);
  final userData = await user.get();
try{

  List<Map<String, dynamic>> userGroups = List<Map<String, dynamic>>.from(userData['groups']);
  for (int i = 0; i < userGroups.length; i++) {
    if (userGroups[i]['groupId'] == groupId) {

      userGroups[i]['admin'] = isAdmin;
      break;
    }
  }


  await user.update({
    'groups': userGroups,
  });
}catch(e){
  print(e.toString());
}
}

Future<void> updateNotificationsForCurrentUser(String userId,bool adminStatus)async{

}

Future<void> addGroupIdToNewMembers(String groupId, List<String> users) async {
  final usersDb = FirebaseFirestore.instance.collection('Users');

  try {
    for (var user in users) {
      await usersDb.doc(user).update({
        "groups": FieldValue.arrayUnion([
          {
            "groupId": groupId,
            "admin": false,
          }
        ])
      });
    }
  } catch (e) {
    print("Error updating users: ${e.toString()}");
  }finally{
    print("New group added to the member");
  }
}