import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference usersDb = FirebaseFirestore.instance.collection("Users");

Future<List<String>> getUserNames(List<String> usersUid) async {
  List<String> userNames = [];

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


Future<void> addGroupAndAddActiveGroupInDatabase(String groupId, String path) async {
  try {
    DocumentReference userRef = usersDb.doc(path);
    DocumentSnapshot snapshot = await userRef.get();

    if (!snapshot.exists) {
      print("User document not found");
      return;
    }

    List<String> groupList = List<String>.from(snapshot.get("groups") ?? []);

    if (!groupList.contains(groupId)) {
      groupList.add(groupId);
      await userRef.update({"groups": groupList});
      print("Group added successfully");
    } else {
      print("Group already exists");
    }
  } catch (e) {
    print("Error: ${e.toString()}");
  }
}
