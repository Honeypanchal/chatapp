import 'package:chatapp/Pages/GroupChatLayout/new_group_definition.dart';
import 'package:chatapp/models/CustomClass.dart';
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
  CollectionReference groupsDB =
      FirebaseFirestore.instance.collection("groups");
  TextEditingController _searchText = new TextEditingController();
  dynamic _Chatdatabase = '';
  bool isMakingGroupChat = false;

  List _chatUsers = [];
  List<Map<String, dynamic>> groupChatUsers = [];

  // Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchGroups() {
  //
  //   return groupsDB.snapshots().map((querySnapshot) {
  //
  //     return querySnapshot.docs
  //         as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
  //   });
  // }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() {
    if (_searchText.text.isNotEmpty) {
      return _database
          .where("firstName", isEqualTo: _searchText.text.trim())
          .snapshots()
          .map((snapshot) {
        return snapshot.docs;
      });
    } else {
      return _database.snapshots().map((snapshot) {

        snapshot.docs.sort((a, b) => a['firstName'].compareTo(b['firstName']));
        return snapshot.docs;
      });
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
            // child: Container(
            //   height: width > 600 ? width * 0.1 : width * 0.045,
            //   width: width > 600 ? width * 0.1 : width * 0.035,
            //   decoration:
            //       BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            //   child: Center(
            //     child: Padding(
            //       padding: EdgeInsets.only(left: width * 0.019),
            //       child: Icon(
            //         Icons.arrow_back_ios,
            //         size: width > 600 ? width * 0.6 : width * 0.044,
            //       ),
            //     ),
            //   ),
            // ),
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
                StreamBuilder<
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                  stream: fetchUsers(), // This should return a Stream
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

    if (_chatUsers[index]['uid'] == widget.currentUser.uid) {
      return Container(); // Skip current user
    }
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
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: groupChatUsers.any((x) =>
                                          x['uid'] == _chatUsers[index]['uid'])
                                      ? Colors.blue.shade600
                                      : Colors.black,
                                  width: width * 0.002,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Text(
                                    "${_chatUsers[index]['firstName'][0].toUpperCase()}"),
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
                // StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                //   stream: fetchGroups(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return Center(child: CircularProgressIndicator());
                //     }
                //
                //     if (snapshot.hasError) {
                //       return Center(child: Text("Error: ${snapshot.error}"));
                //     }
                //
                //
                //     return ListView.builder(shrinkWrap: true,
                //       itemCount: snapshot.data!.length,
                //       itemBuilder: (context, index) {
                //         var group = snapshot.data![index].data();
                //         return ListTile(
                //           title: Text(group['groupName'] ?? 'No Group Name'),
                //           subtitle: Text('Members: ${group['membersCount'] ?? 0}'),
                //         );
                //       },
                //     );
                //   },
                // )



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
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => NewGroupDefinition(
                        createdBy: widget.currentUser,
                        members: List.from(groupChatUsers))))
                .then((_) {
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
          size: width < 600 ? width * 0.08 : width * 0.09,
        ), // Tooltip for the button
      ),
    );
  }
}
