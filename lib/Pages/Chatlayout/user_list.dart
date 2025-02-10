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
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }


  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((user) => user['firstName'].toLowerCase().contains(query))
          .toList();
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

  Future<void> loadUsers() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      QuerySnapshot querySnapshot = await _database.get();
      List<Map<String, dynamic>> users = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _allUsers = users.where((user) => user['uid'] != widget.currentUser.uid).toList();
        _filteredUsers = _allUsers;
        _isLoading = false; // Stop loading after data is fetched
      });
    } catch (error) {
      print("Error loading users: $error");
      setState(() {
        _isLoading = false; // Stop loading even if an error occurs
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        title: Text('Select a User', style: TextStyle(color: Colors.black)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              // height: height * 0.052,
              width: width > 600 ? width * 1 : width * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(width > 600 ? width * 0.013 :width * 0.03),
              ),
              child: TextField(
                cursorColor: Color.fromRGBO(21, 171, 97, 1),
                controller: _searchController,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Raleway',
                ),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(child: Text("No users available."))
                : ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> user = _filteredUsers[index];
                return ListTile(
                  onTap: () {
                    navigateToChat(user);
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: Text(
                      "${user['firstName'][0].toUpperCase()}",
                      style: TextStyle(color: Colors.black),
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
            ),
          ),
        ],
      ),
    );
  }
}
