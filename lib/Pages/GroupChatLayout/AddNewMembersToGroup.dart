import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/groupChat_services.dart';
import '../../services/users_services.dart';

class AddNewMembersToGroup extends StatefulWidget {
  final List<String> existingMembers;
  final String groupId;

  const AddNewMembersToGroup(
      {super.key, required this.existingMembers, required this.groupId});

  @override
  State<AddNewMembersToGroup> createState() => _AddNewMembersToGroupState();
}

class _AddNewMembersToGroupState extends State<AddNewMembersToGroup> {
  List<String> newMembers = [];
  List<String> newMembersName=[];
  final _database = FirebaseFirestore.instance.collection('Users');
  TextEditingController _searchText = TextEditingController();
  bool _isSearching = false;

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() {
    return _database.snapshots().map((snapshot) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredUsers = snapshot
          .docs
          .where((doc) => !widget.existingMembers.contains(doc['uid']))
          .toList();

      if (_searchText.text.isNotEmpty) {
        filteredUsers = filteredUsers
            .where((doc) => doc['firstName']
                .toString()
                .toLowerCase()
                .contains(_searchText.text.trim().toLowerCase()))
            .toList();
      }

      filteredUsers.sort((a, b) => a['firstName'].compareTo(b['firstName']));
      return filteredUsers;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchText.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _isSearching
            ? TextField(
          cursorColor: Colors.grey,
                controller: _searchText,
                autofocus: true,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Search users...",
                  hintStyle: TextStyle(color: Colors.black),
                  border:UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)
                )
                ),

              )
            : Column(
          mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Add Members",
                    style: TextStyle(color: Colors.black, fontFamily: 'Raleway',fontSize: width*0.043),
                  ),
                Text(
                  "${newMembers.length} new members added ",
                  style: TextStyle(color: Colors.black, fontFamily: 'Raleway',fontSize: width*0.032),
                ),
              ],
            ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchText.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(

        child: Column(
        
          children: [
          if(newMembers.isNotEmpty && newMembersName.isNotEmpty)...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.012, horizontal: width * 0.012),
              child: SizedBox(
                height: height*0.1, // Ensure enough height for ListView
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: newMembers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.02), // Adjust spacing
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
                              radius: width * 0.07,
                              backgroundColor: Colors.white,
                              child: Text(
                              newMembersName[index][0].toUpperCase(),
                               style: TextStyle( color: Color.fromRGBO(21, 171, 97, 1)),
                              ),
                            ),
                          ),
                          Text(newMembersName[index])
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            Divider(
              height: height*0.012,
              thickness: width*0.0005,
              color: Colors.grey,
            )
          ],
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: height * 0.012, horizontal: width * 0.012),
              child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
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
                            Container(
                        decoration: BoxDecoration(
                        shape: BoxShape.circle,
                          border: Border.all(
                            color:Color.fromRGBO(21, 171, 97, 1), // Set the border color
                            width: width*0.002, // Set the border width
                          ),
                        ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: width * 0.05,
                                child: Text(
                                 user['firstName'][0].toUpperCase(),
                                  style: TextStyle(color: Color.fromRGBO(21, 171, 97, 1)),
                                ),
                              ),
                            ),
                            if (newMembers.contains(user['uid']))
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
                            if (newMembers.contains(user['uid'])) {
                              newMembers.remove(user['uid']);
                            } else {
                              newMembers.add(user['uid']);
                            }
                          });
                          setState(() {
                            if (newMembersName.contains(user['firstName'])) {
                              newMembersName.remove(user['firstName']);
                            } else {
                              newMembersName.add(user['firstName']);
                            }
                          });
                        },
                        tileColor:newMembers.contains(user['uid']) ? Colors.grey.shade300
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
       for(var singleMember in newMembers){
         widget.existingMembers.add(singleMember);
       }

    try{
      addNewMembersToGroup(widget.groupId,newMembers);
      addGroupIdToNewMembers(widget.groupId,newMembers);
      newMembersName.clear();
      newMembers.clear();
      Navigator.of(context).pop();

    }catch(e){
         print(e.toString());
    }

        },
        backgroundColor: Color.fromRGBO(21, 171, 97, 1),
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }
}
