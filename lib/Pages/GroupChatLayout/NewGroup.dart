import 'package:chatapp/Pages/GroupChatLayout/GroupDisplayPage.dart';
import 'package:chatapp/pages/GroupChatLayout/NewGroupDefinition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/CustomClass.dart';

class NewGroup extends StatefulWidget {
  final CustomClass currentUser;

  const NewGroup({super.key, required this.currentUser});

  @override
  State<NewGroup> createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  final _database = FirebaseFirestore.instance.collection('Users');
  CollectionReference groupsDB =
      FirebaseFirestore.instance.collection("groups");
  bool _showSearch = false;
  TextEditingController _searchText = TextEditingController();
  List<String> firstNames = [];

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (_showSearch) {
      return AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => setState(() => _showSearch = false),
        ),
        title: TextField(
cursorColor:              Color.fromRGBO(21, 171, 97, 1),
          controller: _searchText,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            focusColor:Color.fromRGBO(21, 171, 97, 1),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color:Color.fromRGBO(21, 171, 97, 1),)),
            hintText: 'Search users...',
            hintStyle: TextStyle(color: Colors.black),
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
      );
    }

    return AppBar(
      leading: Padding(
        padding: EdgeInsets.only(left:width>600? 0.00:  width * 0.064),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context,'/groupDisplay',arguments: {'currentUser':widget.currentUser})
       ,   child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: width > 600 ? width * 0.02 : width * 0.06,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Group',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: width > 600 ? width * 0.02 : width * 0.06,
            ),
          ),
          Text(
            "Add members",
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontSize: width > 600 ? width * 0.01 : width * 0.032,
            ),
          )
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.black),
          onPressed: () => setState(() => _showSearch = true),
        ),
      ],
    );
  }
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() {
    if (_searchText.text.isNotEmpty) {
      String searchTerm = _searchText.text.trim();

      return _database
          .where("firstName", isEqualTo: searchTerm)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .where((user) => user['uid'] != widget.currentUser.uid)
          .toList());
    }

    return _database.snapshots().map((snapshot) {
      var filteredDocs = snapshot.docs
          .where((user) => user['uid'] != widget.currentUser.uid)
          .toList();

      filteredDocs.sort((a, b) => a['firstName'].compareTo(b['firstName']));
      return filteredDocs;
    });
  }

  List<String> groupChatUsers = [];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.012, vertical: height * 0.012),
              child: Column(
                children: [
                  if (groupChatUsers.isNotEmpty && firstNames.isNotEmpty)
                    SizedBox(
                      height: height * 0.12,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: firstNames.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.02, vertical: height * 0.012),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:Color.fromRGBO(21, 171, 97, 1), // Set the border color
                                      width: width*0.002, // Set the border width
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: width * 0.067,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      firstNames[index][0].toUpperCase(),
                                      style: TextStyle(color: Color.fromRGBO(21, 171, 97, 1)),
                                    ),
                                  ),
                                )
,
                                Text(firstNames[index])
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  Divider(
                    thickness: width * 0.00015,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                      stream: fetchUsers(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator(backgroundColor: Colors.white,color: Color.fromRGBO(21, 171, 97, 1),));
                        }

                        var users = snapshot.data!;
                        if (users.isEmpty) return Center(child: Text("No users found"));

                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            var user = users[index];
                            return ListTile(
                              leading: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Color.fromRGBO(21, 171, 97, 1), // Border color
                                        width: width*0.002, // Border width
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor:Colors.white,
                                      radius: width * 0.05,
                                      child: Text(
                                        user['firstName'][0].toUpperCase(),
                                        style: TextStyle(color:  Color.fromRGBO(21, 171, 97, 1)),
                                      ),
                                    ),
                                  )
                                  ,
                                  if (groupChatUsers.contains(user['uid']))
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          size: width * 0.035,
                                          color: Color.fromRGBO(21, 171, 97, 1),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(user['firstName']),
                              onTap: () {
                                setState(() {
                                  if (groupChatUsers.contains(user['uid'])) {
                                    groupChatUsers.remove(user['uid']);
                                    firstNames.remove(user['firstName']);
                                  } else {
                                    groupChatUsers.add(user['uid']);
                                    firstNames.add(user['firstName']);
                                  }
                                });
                              },
                              tileColor: groupChatUsers.contains(user['uid'])
                                  ? Colors.grey.shade300
                                  : Colors.transparent,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),


        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (groupChatUsers.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Add atleast one member to  new  group",
                style: TextStyle(color: Colors.white, fontFamily: 'Raleway'),
              ),
              backgroundColor: Colors.red.shade200,
            ));
          } else {
            //Adding the current user also to the group;
            groupChatUsers.add(widget.currentUser.uid);
            Navigator.pushNamed(context,'/newGroupDefinition',  arguments: {'currentUser': widget.currentUser,'members':groupChatUsers},).then((_){
              setState(() {
                groupChatUsers.clear();
                firstNames.clear();
              });
            });

          }
        },
        backgroundColor:Color.fromRGBO(21, 171, 97, 1),
        child: Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }
}
