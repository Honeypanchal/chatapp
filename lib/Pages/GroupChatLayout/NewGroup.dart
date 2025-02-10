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
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => _showSearch = false),
        ),
        title: TextField(
cursorColor: Colors.green.shade700,
          controller: _searchText,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            focusColor: Colors.green.shade700,
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color:Colors.green.shade700)),
            hintText: 'Search users...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
      );
    }

    return AppBar(
      leading: Padding(
        padding: EdgeInsets.only(left: width * 0.064),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context,'/groupDisplay',arguments: {'currentUser':widget.currentUser})
       ,   child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: width > 600 ? width * 0.6 : width * 0.06,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Group',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: width > 600 ? width * 0.05 : width * 0.06,
            ),
          ),
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
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
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
          if (groupChatUsers.isNotEmpty && firstNames.length == groupChatUsers.length) ...[
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                   horizontal: width * 0.032),
                child: SizedBox(
                  height: width * 0.15,
                  child: Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: groupChatUsers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.02,
                              vertical: height * 0.012),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: width * 0.067,
                                backgroundColor: Colors.black,
                                child: Text(firstNames[index][0].toUpperCase(),style: TextStyle(color: Colors.green.shade700),)
                              ),
                              Text(firstNames[index])
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Divider(

              thickness: width * 0.00015,
              color: Colors.grey,
            )
          ],
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.012, vertical: height * 0.012),
              child:  StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                stream: fetchUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  var users = snapshot.data!;
                  if (users.isEmpty) return Center(child: Text("No users found"));

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      return ListTile(
                        leading:Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: width * 0.05,
                              child: Text(
                                user['firstName'][0].toUpperCase(),
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ),
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
                                    color: Colors.green.shade700,
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
                            } else {
                              groupChatUsers.add(user['uid']);
                            }
                          });
                          setState(() {
                            if (firstNames.contains(user['firstName'])) {
                              firstNames.remove(user['firstName']);
                            } else {
                              firstNames.add(user['firstName']);
                            }
                          });
                        },
                        tileColor:groupChatUsers.contains(user['uid']) ? Colors.grey.shade300
                            : Colors.transparent,
                      );
                    },
                  );
                },
              )
            ),
          ),
        ],
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
        backgroundColor: Colors.black,
        child: Icon(
          Icons.arrow_forward,
          color: Colors.green.shade700,
        ),
      ),
    );
  }
}
