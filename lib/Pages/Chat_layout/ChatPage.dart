import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chat_layout/chat_layout.dart';
import 'package:chatapp/Pages/Chat_layout/user_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    );
  }
}


/*import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chat_layout/chat_layout.dart';
import 'package:chatapp/Pages/Chat_layout/user_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            leading: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.black)
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

      */
/*floatingActionButton: FloatingActionButton(

        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UserListPage(currentUser: widget.currentUser),
          ));
        },

        backgroundColor: Colors.green.shade700,
        child: Icon(Icons.add, color: Colors.black, size: 40, weight: 15),
      ),*/
/*
    );
  }
}*/



/*import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chat_layout/chat_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> loadSelectedUsers() async {
    DocumentSnapshot userDoc = await _database.doc(widget.currentUser.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      List<dynamic> savedUsers = userDoc.get("selectedUsers") ?? [];
      setState(() {
        _selectedUsers = List<Map<String, dynamic>>.from(savedUsers);
      });
    }
  }

  Future<void> saveSelectedUsers() async {
    await _database.doc(widget.currentUser.uid).update({
      "selectedUsers": _selectedUsers,
    });
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
            fontSize: width > 600 ? width * 0.05 : width * 0.06,
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
      :_selectedUsers.isEmpty
          ? Center(child: Text("No chats available. Click + to start a chat."))
          : ListView.builder(
        itemCount: _selectedUsers.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () => navigateToChat(_selectedUsers[index]),
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text(
                "${_selectedUsers[index]['firstName'][0].toUpperCase()}",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w500,
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                future: _database.get().then((snapshot) => snapshot.docs),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No users available."));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          Map<String, dynamic> selectedUser = snapshot.data![index].data();
                          setState(() {
                            if (!_selectedUsers.any((user) => user['uid'] == selectedUser['uid'])) {
                              _selectedUsers.add(selectedUser);
                            }
                          });
                          await saveSelectedUsers();
                          Navigator.pop(context);
                          navigateToChat(selectedUser);
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,

                          child: Text(
                            "${snapshot.data![index]['firstName'][0].toUpperCase()}",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w500,
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
              );
            },
          );
        },
        child: Icon(Icons.add,color: Colors.black,size: 40,weight: 15,),
        backgroundColor: Color(0xFF25D366),
      ),
    );
  }
}*/


/*
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chat_layout/chat_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    loadSelectedUsers();
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

  Future<void> saveSelectedUsers() async {
    await _database.doc(widget.currentUser.uid).update({
      "selectedUsers": _selectedUsers,
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: width > 600 ? width * 0.05 : width * 0.06,
          ),
        ),
      ),
      body: _selectedUsers.isEmpty
          ? Center(child: Text("No chats available. Click + to start a chat."))
          : ListView.builder(
        itemCount: _selectedUsers.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              String docId = widget.currentUser.uid.compareTo(_selectedUsers[index]['uid']) < 0
                  ? "${widget.currentUser.uid}_${_selectedUsers[index]['uid']}"
                  : "${_selectedUsers[index]['uid']}_${widget.currentUser.uid}";

              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatLayout(
                  currentUser: widget.currentUser,
                  user: _selectedUsers[index],
                  databaseRef: chatsDB.doc(docId),
                ),
              ));
            },
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "${_selectedUsers[index]['firstName'][0].toUpperCase()}",
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                future: _database.get().then((snapshot) => snapshot.docs),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No users available."));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          setState(() {
                            if (!_selectedUsers.any((user) => user['uid'] == snapshot.data![index]['uid'])) {
                              _selectedUsers.add(snapshot.data![index].data());
                            }
                          });
                          await saveSelectedUsers();
                          Navigator.pop(context);
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            "${snapshot.data![index]['firstName'][0].toUpperCase()}",
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
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
*/




/*

import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chat_layout/chat_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() async {
    final users = await _database.get();
    return users.docs;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: width > 600 ? width * 0.05 : width * 0.06,
          ),
        ),
      ),
      body: _selectedUsers.isEmpty
          ? Center(child: Text("No chats available. Click + to start a chat."))
          : ListView.builder(
        itemCount: _selectedUsers.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              String docId = widget.currentUser.uid.compareTo(_selectedUsers[index]['uid']) < 0
                  ? "${widget.currentUser.uid}_${_selectedUsers[index]['uid']}"
                  : "${_selectedUsers[index]['uid']}_${widget.currentUser.uid}";

              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatLayout(
                  currentUser: widget.currentUser,
                  user: _selectedUsers[index],
                  databaseRef: chatsDB.doc(docId),
                ),
              ));
            },
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "${_selectedUsers[index]['firstName'][0].toUpperCase()}",
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                future: fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No users available."));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          setState(() {
                            if (!_selectedUsers.any((user) => user['uid'] == snapshot.data![index]['uid'])) {
                              _selectedUsers.add(snapshot.data![index].data());
                            }
                          });
                          Navigator.pop(context);
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            "${snapshot.data![index]['firstName'][0].toUpperCase()}",
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
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
*/




/*
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chat_layout/chat_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final CustomClass currentUser;

  ChatPage({required this.currentUser});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _database = FirebaseFirestore.instance.collection('Users');
  dynamic chatsDB = FirebaseFirestore.instance.collection("chats");
  List _chatUsers = [];

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() async {
    final users = await _database.get();
    return users.docs;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: width > 600 ? width * 0.05 : width * 0.06,
          ),
        ),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No chats available. Click + to start a chat."));
          }

          _chatUsers = snapshot.data!;

          return ListView.builder(
            itemCount: _chatUsers.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  String docId = widget.currentUser.uid.compareTo(_chatUsers[index]['uid']) < 0
                      ? "${widget.currentUser.uid}_${_chatUsers[index]['uid']}"
                      : "${_chatUsers[index]['uid']}_${widget.currentUser.uid}";

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatLayout(
                      currentUser: widget.currentUser,
                      user: _chatUsers[index],
                      databaseRef: chatsDB.doc(docId),
                    ),
                  ));
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    "${_chatUsers[index]['firstName'][0].toUpperCase()}",
                  ),
                ),
                title: Text(
                  "${_chatUsers[index]['firstName']} ",
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                future: fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No users available."));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          String docId = widget.currentUser.uid.compareTo(snapshot.data![index]['uid']) < 0
                              ? "${widget.currentUser.uid}_${snapshot.data![index]['uid']}"
                              : "${snapshot.data![index]['uid']}_${widget.currentUser.uid}";

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChatLayout(
                              currentUser: widget.currentUser,
                              user: snapshot.data![index],
                              databaseRef: chatsDB.doc(docId),
                            ),
                          ));
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            "${snapshot.data![index]['firstName'][0].toUpperCase()}",
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
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
*/


// original
/*
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chat_layout/chat_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final CustomClass currentUser;

  ChatPage({
    required this.currentUser,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _database = FirebaseFirestore.instance.collection('Users');
  dynamic chatsDB = FirebaseFirestore.instance.collection("chats");
  TextEditingController _searchText = TextEditingController();
  dynamic _Chatdatabase = '';

  List _chatUsers = [];

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() async {
    if (_searchText.text.isNotEmpty) {
      final users = await _database
          .where("firstName", isEqualTo: _searchText.text.trim().toString())
          .get();
      return users.docs;
    } else {
      final users = await _database.get();
      return users.docs;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchText.addListener(() {
      fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchText.removeListener(() {});
    _searchText.dispose(); // Don't forget to dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: width * 0.064),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: width > 600 ? width * 0.6 : width * 0.06,
            ),
          ),
        ),
        backgroundColor: Colors.blue[600],
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: width > 600 ? width * 0.05 : width * 0.06,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;

          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: isWeb ? width * 0.1 : width * 0.012,
              vertical: height * 0.012,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.01,
                        right: width * 0.01,
                        top: height * 0.018,
                        bottom: height * 0.01),
                    child: Container(
                      height: height * 0.052,
                      width: isWeb ? width * 0.9 : width * 0.9,
                      decoration: BoxDecoration(
                        boxShadow: [],
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      child: TextField(
                        controller: _searchText,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Raleway',
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Raleway',
                          ),
                          hintText: 'Search',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.025),

                // FutureBuilder to fetch users
                FutureBuilder<
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                  future: fetchUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No users found"));
                    }

                    _chatUsers = snapshot.data!;

                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _chatUsers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              String docId = widget.currentUser.uid
                                  .compareTo(_chatUsers[index]['uid']) <
                                  0
                                  ? "${widget.currentUser.uid}_${_chatUsers[index]['uid']}"
                                  : "${_chatUsers[index]['uid']}_${widget.currentUser.uid}";
                              _Chatdatabase = chatsDB.doc(docId);

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatLayout(
                                  currentUser: widget.currentUser,
                                  user: _chatUsers[index],
                                  databaseRef: _Chatdatabase,
                                ),
                              ));
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text(
                                "${_chatUsers[index]['firstName'][0].toUpperCase()}",
                              ),
                            ),
                            title: Text(
                              "${_chatUsers[index]['firstName']} ",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
*/



/*

import 'package:chatapp/Pages/GroupChatLayout/new_group_definition.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chat_layout/chat_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../GroupChatLayout/NewGroupDefinition.dart';

class ChatPage extends StatefulWidget {
  final CustomClass currentUser;

  ChatPage({
    required this.currentUser,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _database = FirebaseFirestore.instance.collection('Users');
  dynamic chatsDB = FirebaseFirestore.instance.collection("chats");
  TextEditingController _searchText = new TextEditingController();
  dynamic _Chatdatabase = '';
  bool isMakingGroupChat = false;

  List _chatUsers = [];
  List<Map<String, dynamic>> groupChatUsers = [];

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() async {
    if (_searchText.text.isNotEmpty) {
      final users = await _database
          .where("firstName", isEqualTo: _searchText.text.trim().toString())
          .get();
      return users.docs;
    } else {
      final users = await _database.get();
      return users.docs;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchText.addListener(() {
      fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchText.removeListener(() {});
    _searchText.dispose(); // Don't forget to dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: width * 0.064),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: width > 600 ? width * 0.6 : width * 0.06,
            ),
          ),
        ),
        backgroundColor: Colors.blue[600],
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMakingGroupChat ? 'New Group' : 'Chats',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: width > 600 ? width * 0.05 : width * 0.06,
              ),
            ),
            if (isMakingGroupChat)
              Text(
                "Add members",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: width > 600 ? width * 0.04 : width * 0.032,
                ),
              )
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;

          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: isWeb ? width * 0.1 : width * 0.012,
              vertical: height * 0.012,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMakingGroupChat)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: height * 0.012, horizontal: width * 0.012),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: groupChatUsers.map((x) {
                        return CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Colors.blue[600],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.01,
                        right: width * 0.01,
                        top: height * 0.018,
                        bottom: height * 0.01),
                    child: Container(
                      height: height * 0.052,
                      width: isWeb ? width * 0.9 : width * 0.9,
                      decoration: BoxDecoration(
                        boxShadow: [],
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      child: TextField(
                        controller: _searchText,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Raleway',
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Raleway',
                          ),
                          hintText: 'Search',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.025),

                // FutureBuilder to fetch users
                FutureBuilder<
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                  future: fetchUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No users found"));
                    }

                    _chatUsers = snapshot.data!;

                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _chatUsers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onLongPress: () {
                              if (isMakingGroupChat) {
                                setState(() {
                                  bool exists = groupChatUsers.any((x) =>
                                      x['uid'] == _chatUsers[index]['uid']);

                                  if (exists) {
                                    groupChatUsers.removeWhere((x) =>
                                        x['uid'] == _chatUsers[index]['uid']);
                                  } else {
                                    groupChatUsers
                                        .add(_chatUsers[index].data());
                                  }
                                });

                                print(groupChatUsers.length);
                              }
                            },
                            onTap: () {
                              String docId = widget.currentUser.uid
                                          .compareTo(_chatUsers[index]['uid']) <
                                      0
                                  ? "${widget.currentUser.uid}_${_chatUsers[index]['uid']}"
                                  : "${_chatUsers[index]['uid']}_${widget.currentUser.uid}";
                              _Chatdatabase = chatsDB.doc(docId);

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatLayout(
                                  currentUser: widget.currentUser,
                                  user: _chatUsers[index],
                                  databaseRef: _Chatdatabase,
                                ),
                              ));
                            },
                            leading: Container(
                              padding: EdgeInsets.all(width * 0.002),
                              // Border thickness
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: groupChatUsers.any((x) =>
                                            x['uid'] ==
                                            _chatUsers[index]['uid'])
                                        ? Colors.blue.shade600
                                        : Colors.black,
                                    width: width * 0.002), // Border color
                              ),
                              child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child:
                                      // Icon(
                                      //   Icons.person,
                                      //   color: Colors.blue[600],
                                      // ),
                                      Text(
                                          "${_chatUsers[index]['firstName'][0].toUpperCase()}")),
                            ),
                            title: Text(
                              "${_chatUsers[index]['firstName']} ",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isMakingGroupChat && groupChatUsers.isNotEmpty) {
            //pushing currentUser
            groupChatUsers.add(widget.currentUser.toMap());
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    NewGroupDefinition(createdBy: widget.currentUser,
                        members: List.from(groupChatUsers)))).then((_) {
              isMakingGroupChat = !isMakingGroupChat;
              setState(() {
                groupChatUsers.clear();
              });
            });
          } else {
            setState(() {
              isMakingGroupChat = !isMakingGroupChat;
            });
          }
        },
        backgroundColor: Colors.blue[600],
        tooltip: 'Create New Group',
        child: Icon(
          isMakingGroupChat ? Icons.arrow_forward : Icons.group_add,
          color: Colors.white,
          size: width < 600 ? width* 0.08 : width *0.09,
        ), // Tooltip for the button
      ),
    );
  }
}
*/
