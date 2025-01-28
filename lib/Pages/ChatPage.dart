import 'package:chatapp/Authentication/CustomClass.dart';
import 'package:chatapp/Pages/chat_layout.dart';
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
dynamic _Chatdatabase='';
  List _chatUsers = [];

  Future<void> fetchUsers() async {
    final users = await _database.get();
    _chatUsers = users.docs;
    print(_chatUsers[0]['email']);
  }

  final _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    setState(() {});
    fetchUsers();
  }

  void _filterUsers(String query) {}

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Color(0xFF242935),
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: width * 0.064),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: width * 0.045,
                width: width * 0.035,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: width * 0.019),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: width * 0.044,
                    ),
                  ),
                ),
              ),
            ),
          ),
          backgroundColor: Color(0xFF242935),
          title: Text(
            'Chats',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: width * 0.052),
          ),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(
              horizontal: width * 0.012, vertical: height * 0.012),
          child: Column(
            children: [
              Container(
                height: height * 0.052,
                width: width * 0.9,
                decoration: BoxDecoration(
                    color: Color(0xFF2C313F),
                    borderRadius: BorderRadius.circular(width * 0.09),
                    border: Border.all(color: Colors.white, width: 0.2)),
                child: TextField(
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Raleway',
                    ),
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.025,
              ),
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
//Creating uniwue docid for each chat between two users
                      String docId = widget.currentUser.uid
                                  .compareTo(_chatUsers[index]['uid']) <
                              0
                          ? "${ widget.currentUser.uid}_${_chatUsers[index]['uid']}"
                          : "${_chatUsers[index]['uid']}_${widget.currentUser.uid}";
                       _Chatdatabase=chatsDB.doc(docId);

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatLayout(
                              currentUser: widget.currentUser,
                              user: _chatUsers[index],
                              databaseRef: _Chatdatabase)));
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF995BF8),
                      ),
                    ),
                    title: Text(
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w500),
                        "${_chatUsers[index]['firstName']}  ${_chatUsers[index]['lastName']}"),
                  );
                },
                itemCount: _chatUsers.length,
              ),
            ],
          ),
        ));
  }
}
