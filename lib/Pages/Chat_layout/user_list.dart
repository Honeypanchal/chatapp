import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chat_layout/chat_layout.dart';

class UserListPage extends StatefulWidget {
  final CustomClass currentUser;
  UserListPage({required this.currentUser});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _database = FirebaseFirestore.instance.collection('Users');
  dynamic chatsDB = FirebaseFirestore.instance.collection("chats");

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
        leading: Icon(Icons.arrow_back_ios_new,color: Colors.white,),
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

          return ListView.builder(

            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () => navigateToChat(snapshot.data![index].data()),
                leading: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(100)
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      "${snapshot.data![index]['firstName'][0].toUpperCase()}",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                title: Text(
                  "${snapshot.data![index]['firstName']} ",
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