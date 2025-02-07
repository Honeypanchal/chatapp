import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chatlayout/chat_layout.dart';

class UserListPage extends StatefulWidget {
  final CustomClass currentUser;
  UserListPage({required this.currentUser});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _database = FirebaseFirestore.instance.collection('Users');
  dynamic chatsDB = FirebaseFirestore.instance.collection("chats");
  List<Map<String, dynamic>> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    loadSelectedUsers();
  }

  // Load selected users from Firestore
  Future<void> loadSelectedUsers() async {
    DocumentSnapshot userDoc = await _database.doc(widget.currentUser.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      List<dynamic> savedUsers = userDoc.get("selectedUsers") ?? [];
      setState(() {
        _selectedUsers = List<Map<String, dynamic>>.from(savedUsers);
      });
    }
  }

  // Navigate to chat with selected user
  void navigateToChat(Map<String, dynamic> user) {
    String docId = widget.currentUser.uid.compareTo(user['uid']) < 0
        ? "${widget.currentUser.uid}_${user['uid']}"
        : "${user['uid']}_${widget.currentUser.uid}";

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatLayout(
        currentUser: widget.currentUser,
        user: user,
        databaseRef: chatsDB.doc(docId),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // This will navigate back to the previous screen
          },
        ),
        backgroundColor: Colors.black,
        title: Text(
          'Select a User',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _database.get().then((snapshot) => snapshot.docs),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.black));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No users available."));
          }

          // Filter out the selected users from the available users
          List<QueryDocumentSnapshot<Map<String, dynamic>>> availableUsers = snapshot.data!.where((doc) {
            Map<String, dynamic> user = doc.data();
            return !_selectedUsers.any((selectedUser) => selectedUser['uid'] == user['uid']);
          }).toList();

          return ListView.builder(
            itemCount: availableUsers.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> user = availableUsers[index].data();

              return ListTile(
                onTap: () async {
                  // Get the selected user's data
                  Map<String, dynamic> selectedUser = availableUsers[index].data();

                  // Add the selected user to the current user's selected users list in Firestore
                  DocumentReference userDoc = FirebaseFirestore.instance.collection('Users').doc(widget.currentUser.uid);
                  await userDoc.update({
                    'selectedUsers': FieldValue.arrayUnion([selectedUser])
                  });

                  // Navigate back and pass the selected user
                  Navigator.pop(context, selectedUser);
                },
                leading: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      "${user['firstName'][0].toUpperCase()}",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                title: Text(
                  "${user['firstName']} ",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



