import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/ChatLayout/chat_layout.dart';
import 'package:chatapp/Pages/ChatLayout/user_list.dart';
import 'package:chatapp/pages/helpers/MainNavigation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'chat_layout.dart';

class ChatPage extends StatefulWidget {

  final CustomClass currentUser;

  ChatPage({required this.currentUser});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _database = FirebaseFirestore.instance.collection('Users');
  dynamic chatsDB = FirebaseFirestore.instance.collection("chats");
  List<Map<String, dynamic>> _selectedUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSelectedUsers();
  }


  int _selectedIndex=0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/chatPage',
            arguments: {'currentUser': widget.currentUser});
        break;
      case 1:
        Navigator.pushNamed(
          context,
          '/groupDisplay',
          arguments: {'currentUser': widget.currentUser},
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/statusPage');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile',
            arguments: {'currentUser': widget.currentUser});
        break;
    }
  }
  Future<void> loadSelectedUsers() async {
    DocumentSnapshot userDoc = await _database.doc(widget.currentUser.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      List<dynamic> savedUsers = userDoc.get("selectedUsers") ?? [];
      setState(() {
        _selectedUsers = List<Map<String, dynamic>>.from(savedUsers);
      });
    }
  }

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

  // Function to delete user and chat
  void deleteUserAndChat(Map<String, dynamic> user) async {
    DocumentReference userDoc = FirebaseFirestore.instance.collection('Users').doc(widget.currentUser.uid);

    // Remove the user from the selectedUsers list in Firestore
    await userDoc.update({
      'selectedUsers': FieldValue.arrayRemove([user])
    });

    // Delete the chat associated with this user
    String docId = widget.currentUser.uid.compareTo(user['uid']) < 0
        ? "${widget.currentUser.uid}_${user['uid']}"
        : "${user['uid']}_${widget.currentUser.uid}";

    await chatsDB.doc(docId).delete();

    // Update the local list
    setState(() {
      _selectedUsers.removeWhere((selectedUser) => selectedUser['uid'] == user['uid']);
    });

    // Optionally, show a Snackbar or feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${user['firstName']} and chat deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : _selectedUsers.isEmpty
          ? Center(child: Text("No chats available. Click + to start a chat."))
          : ListView.builder(
        itemCount: _selectedUsers.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () => navigateToChat(_selectedUsers[index]),
            onLongPress: () {
              // Show confirmation dialog to delete user and chat
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete User'),
                    content: Text(
                        'Are you sure you want to delete ${_selectedUsers[index]['firstName']} and their chat?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Call the delete function
                          deleteUserAndChat(_selectedUsers[index]);
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text('Yes', style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text('No'),
                      ),
                    ],
                  );
                },
              );
            },
            leading: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.black),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "${_selectedUsers[index]['firstName'][0].toUpperCase()}",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            title: Text(
              "${_selectedUsers[index]['firstName']} ",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to UserListPage and wait for the selected user to return
          Map<String, dynamic>? selectedUser = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserListPage(currentUser: widget.currentUser),
            ),
          );

          // If a user is selected, add to the _selectedUsers list and update the UI
          if (selectedUser != null) {
            setState(() {
              _selectedUsers.add(selectedUser);
            });
          }
        },
        backgroundColor: Colors.green.shade700,
        child: Icon(Icons.add, color: Colors.black, size: 40),
      ),
      bottomNavigationBar: MainNavigationPage(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
