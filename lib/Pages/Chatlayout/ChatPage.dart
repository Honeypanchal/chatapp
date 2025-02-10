import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chatlayout/chat_layout.dart';
import 'package:chatapp/Pages/Chatlayout/user_list.dart';
import 'package:chatapp/pages/helpers/MainNavigation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for formatting time


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
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSelectedUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;

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
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot userDoc =
        await _database.doc(widget.currentUser.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      List<dynamic> savedUsers = userDoc.get("selectedUsers") ?? [];
      setState(() {
        _selectedUsers = List<Map<String, dynamic>>.from(savedUsers);
        _filteredUsers = _selectedUsers;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _selectedUsers
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

  Future<Map<String, dynamic>> getLastMessage(String groupId) async {
    var snapshot = await chatsDB
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var lastMessageData = snapshot.docs.first.data();
      return {
        'message': lastMessageData['message'] ?? '',
        'timestamp': lastMessageData['timestamp'] ?? null
      };
    }
    return {'message': 'No messages yet', 'timestamp': null};
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
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
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.black))
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                            "No chats available. Click + to start a chat."))
                    : ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                String docId = widget.currentUser.uid.compareTo(_filteredUsers[index]['uid']) < 0
                    ? "${widget.currentUser.uid}_${_filteredUsers[index]['uid']}"
                    : "${_filteredUsers[index]['uid']}_${widget.currentUser.uid}";


                return ListTile(
                  onTap: () => navigateToChat(_filteredUsers[index]),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: Text(
                      "${_filteredUsers[index]['firstName'][0].toUpperCase()}",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  title: Text(
                    "${_filteredUsers[index]['firstName']} ",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle:FutureBuilder<Map<String, dynamic>>(
                    future: getLastMessage(docId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          "Loading...",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: 'Raleway',
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text(
                          "Error fetching message",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontFamily: 'Raleway',
                          ),
                        );
                      }

                      String lastMessage = snapshot.data?['message'] ?? "";
                      Timestamp? timestamp = snapshot.data?['timestamp'];

                      String formattedTime = "";
                      if (timestamp != null) {
                        DateTime messageTime = timestamp.toDate();
                        DateTime now = DateTime.now();
                        DateTime yesterday = now.subtract(Duration(days: 1));

                        if (DateFormat('yyyy-MM-dd').format(messageTime) == DateFormat('yyyy-MM-dd').format(now)) {
                          formattedTime = DateFormat('HH:mm').format(messageTime); // 24-hour format
                        } else if (DateFormat('yyyy-MM-dd').format(messageTime) == DateFormat('yyyy-MM-dd').format(yesterday)) {
                          formattedTime = "Yesterday";
                        } else {
                          formattedTime = DateFormat('MMM d, yyyy').format(messageTime);
                        }
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage.isNotEmpty ? lastMessage : "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: 'Raleway',
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          if (formattedTime.isNotEmpty) // Show time only if it exists
                            Text(
                              formattedTime,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: 'Raleway',
                              ),

                            ),
                        ],
                      );
                    },
                  ),

                );
              },
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic>? selectedUser = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  UserListPage(currentUser: widget.currentUser),
            ),
          );

          if (selectedUser != null) {
            setState(() {
              _selectedUsers.add(selectedUser);
              _filteredUsers = _selectedUsers;
            });
          }
        },
        backgroundColor: Color.fromRGBO(21, 171, 97, 1),
        tooltip: 'Contact with new User..',
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: width > 600 ? width * 0.025 : width * 0.09,
        ),
      ),

      bottomNavigationBar: MainNavigationPage(
          currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
