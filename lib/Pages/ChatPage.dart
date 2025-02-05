import 'package:chatapp/Pages/helpers/MainNavigation.dart';
import 'package:chatapp/Pages/statuspage.dart';
import 'package:chatapp/pages/GroupChatLayout/NewGroupDefinition.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/chat_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupChatPage.dart';
import 'package:chatapp/models/Group.dart';

class ChatPage extends StatefulWidget {
  final CustomClass currentUser;

  ChatPage({required this.currentUser});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //For Navigation
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:

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
        Navigator.pushNamed(context, '/profile',arguments: {'currentUser':widget.currentUser});
        break;
    }
  }

  final _database = FirebaseFirestore.instance.collection('Users');
  dynamic chatsDB = FirebaseFirestore.instance.collection("chats");
  CollectionReference groupsDB = FirebaseFirestore.instance.collection("groups");
  TextEditingController _searchText = TextEditingController();
  dynamic _Chatdatabase = '';
  bool isMakingGroupChat = false;

  List _chatUsers = [];
  List<String> groupChatUsers = [];

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchGroups() {
    return groupsDB.snapshots().map((querySnapshot) {
      return querySnapshot.docs
      as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
    });
  }

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
    _searchText.dispose();
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
        backgroundColor: Colors.black,
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
      body: SingleChildScrollView( // Scrollable parent widget for the entire body
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.012, vertical: height * 0.012),
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
                  ),
                  child: Container(
                    height: height * 0.052,
                    width: width * 0.9,
                    decoration: BoxDecoration(
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
              if (isMakingGroupChat && groupChatUsers.isNotEmpty)...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.002, horizontal: width * 0.012),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: groupChatUsers.map((x) {
                      return CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.person,
                          color: Colors.blue[600],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Divider(
                  height: height*0.012,
                  thickness: width*0.00015,
                  color: Colors.grey,
                )
              ]
              ,



              // Users StreamBuilder
              StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                stream: fetchUsers(),
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

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // Prevent scrolling inside ListView
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
                              x == _chatUsers[index]['uid']);

                              if (exists) {
                                groupChatUsers.removeWhere((x) =>
                                x == _chatUsers[index]['uid']);
                              } else {
                                groupChatUsers.add(_chatUsers[index]['uid']);
                              }
                            });
                          }
                        },
                        onTap: () {
                          String docId = widget.currentUser.uid
                              .compareTo(_chatUsers[index]['uid']) < 0
                              ? "${widget.currentUser.uid}_${_chatUsers[index]['uid']}"
                              : "${_chatUsers[index]['uid']}${widget.currentUser.uid}";

                          _Chatdatabase = chatsDB.doc(docId);

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChatLayout(
                              currentUser: widget.currentUser,
                              user: _chatUsers[index],
                              databaseRef: _Chatdatabase,
                            ),
                          ));
                        },
                        tileColor:  groupChatUsers.contains(_chatUsers[index]['uid'])
                            ? Colors.grey.shade300
                            : Colors.transparent,
                        leading: Container(
                          padding: EdgeInsets.all(width * 0.002),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: groupChatUsers.any((x) =>
                              x == _chatUsers[index]['uid'])
                                  ? Colors.blue.shade600
                                  : Colors.black,
                              width: width * 0.002,
                            ),
                          ),
                          child:Stack(
                            clipBehavior: Clip.none, // Allows the tick to be placed outside the CircleAvatar's bounds
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: width * 0.05, // Adjust the radius as needed
                                child: Text(
                                  _chatUsers[index]['firstName'][0].toUpperCase(),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              if (groupChatUsers.contains(_chatUsers[index]['uid']))
                                Positioned(
                                  right: -2,  // Move slightly outside the CircleAvatar
                                  bottom: -2, // Move slightly outside the CircleAvatar
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white, // Background for tick to blend with avatar border
                                    ),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: width * 0.035,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                            ],
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

              // Groups StreamBuilder
              StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                stream: fetchGroups(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No groups found"));
                  }

                  // Get current user's ID
                  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

                  // Filter groups where the user is a member
                  var userGroups = snapshot.data!.where((doc) {
                    var group = doc.data();
                    List members = group['participants'] ?? [];
                    return members.contains(currentUserId);
                  }).toList();

                  if (userGroups.isEmpty) {
                    return Center(child: Text("You are not a member of any groups"));
                  }

                  return Column(
                    children: List.generate(userGroups.length, (index) {
                      var groupDoc = userGroups[index];

                      // Use your Group class method
                      Group groupObj = Group(
                        groupName: groupDoc['groupName'],
                        groupIcon: groupDoc['groupIcon'],
                        groupDescription: groupDoc['groupDescription'],
                        createdBy: groupDoc['createdBy'],
                        participants: List<String>.from(groupDoc['participants']),
                        createdAt: groupDoc['createdAt'],
                        groupSettings: groupDoc['groupSettings'],
                        sendMessages: groupDoc['sendMessages'],
                        addOtherMembers: groupDoc['addOtherMembers'],
                        groupId: groupDoc.id, // Assign Firestore ID
                        admins: ['woidoijwfw'],

                      );

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(Icons.group, color: Colors.white),
                        ),
                        title: Text(
                          groupObj.groupName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context)=>Groupchatpage(groupId: groupObj.groupId!, currentUser: widget.currentUser.uid)
                              // builder: (context) => Groupchatpage(newGroup: groupObj,currentUser: widget.currentUser.uid,),
                            ),
                          );
                        },
                      );
                    }),
                  );
                },
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationPage(currentIndex: _selectedIndex,onTap:_onItemTapped),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isMakingGroupChat && groupChatUsers.isNotEmpty) {
            // pushing currentUser
            groupChatUsers.add(widget.currentUser.uid);
            Navigator.of(context)
                .push(MaterialPageRoute(
                builder: (context) => NewGroupDefinition(
                    createdBy: widget.currentUser,
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
        backgroundColor: Colors.black,
        tooltip: 'Create New Group',
        child: Icon(
          isMakingGroupChat ? Icons.arrow_forward : Icons.group_add,
          color: Colors.white,
          size: width < 600 ? width * 0.08 : width * 0.09,
        ),
      ),
    );
  }
}