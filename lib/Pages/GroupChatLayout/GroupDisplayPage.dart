import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/models/CustomClass.dart';

import '../helpers/MainNavigation.dart';

class GroupDisplayPage extends StatefulWidget {
  final CustomClass currentUser;

  const GroupDisplayPage({super.key, required this.currentUser});

  @override
  State<GroupDisplayPage> createState() => _GroupDisplayPageState();
}

class _GroupDisplayPageState extends State<GroupDisplayPage> {
  int _selectedIndex = 1;
  TextEditingController _searchText = TextEditingController();
  CollectionReference groupsDB =
      FirebaseFirestore.instance.collection("groups");
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchText.addListener(() {
      setState(() {
        searchQuery = _searchText.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

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

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchGroups() {
    Query query =
        groupsDB.where("participants", arrayContains: widget.currentUser.uid);

    if (searchQuery.isNotEmpty) {
      String searchLowerBound = searchQuery;
      String searchUpperBound = searchQuery + '\uf8ff';

      query = query
          .where("groupName", isGreaterThanOrEqualTo: searchLowerBound)
          .where("groupName", isLessThan: searchUpperBound);
    }

    return query.snapshots().map((querySnapshot) => querySnapshot.docs
        as List<QueryDocumentSnapshot<Map<String, dynamic>>>);
  }

  Future<Map<String, String>> getLastMessage(String groupId) async {
    var snapshot = await groupsDB
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var lastMessageData = snapshot.docs.first.data();
      return {
        'sender': lastMessageData['sender'] ?? 'Unknown',
        'message': lastMessageData['message'] ?? ''
      };
    }
    return {'sender': '', 'message': 'No messages yet'};
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left:width * 0.064),
          child: width>600?null: Icon(Icons.groups_outlined, color: Colors.black,size:width*0.062,),
        ),
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Groups',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: width > 600 ? width * 0.05 : width * 0.06,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            color: Colors.grey.shade200,
            offset: Offset(0, height * 0.052),
            elevation: 2,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Starred Messages"),
                value: 0,
              ),
              PopupMenuItem(
                child: Text("Create a Group"),
                value: 1,
              ),
            ],
            onSelected: (val) {
              switch (val) {
                case 0: //neha ka code
                  break;
                case 1:
                  Navigator.pushNamed(
                    context,
                    '/newGroup',
                    arguments: {'currentUser': widget.currentUser},
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
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
                cursorColor: Color.fromRGBO(21, 171, 97, 1),
                controller: _searchText,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Raleway',
                ),
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          SizedBox(height: height * 0.025),
          Expanded(
            child: StreamBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: fetchGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(21, 171, 97, 1),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error fetching groups"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No groups found"));
                }

                var groups = snapshot.data!;
                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    var groupData = groups[index].data();
                    var groupId = groupData['groupId'];

                    return FutureBuilder<Map<String, String>>(
                      future: getLastMessage(groupId),
                      builder: (context, lastMessageSnapshot) {
                        String lastMessageText = "No messages yet";
                        String sender = "";

                        if (lastMessageSnapshot.hasData) {
                          sender = lastMessageSnapshot.data!['sender']!;
                          lastMessageText =
                              lastMessageSnapshot.data!['message']!;
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color.fromRGBO(207, 214, 220, 1),
                            child: Icon(Icons.group, color: Colors.white),
                          ),
                          title:
                              Text(groupData["groupName"] ?? "Unnamed Group"),
                          subtitle: sender.isNotEmpty
                              ? Text('$sender: $lastMessageText')
                              : Text(lastMessageText),
                          onTap: () {
                            Navigator.of(context).pushNamed('/groupchat',
                                arguments: {
                                  'groupId': groupId,
                                  "currentUser": widget.currentUser.uid
                                });
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationPage(
          currentIndex: _selectedIndex, onTap: _onItemTapped),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/newGroup',
            arguments: {'currentUser': widget.currentUser},
          );
        },
        backgroundColor: Color.fromRGBO(21, 171, 97, 1),
        tooltip: 'Create New Group',
        child: Icon(
          Icons.group_add,
          color: Colors.white,
          size: width < 600 ? width * 0.08 : width * 0.02
        ),
      ),
    );
  }
}
