
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/models/Group.dart';
import 'package:chatapp/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/groupChat_services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NewGroupDefinition extends StatefulWidget {
  final List<String> members;

  final CustomClass createdBy;

  const NewGroupDefinition(
      {super.key, required this.members, required this.createdBy});

  @override
  State<NewGroupDefinition> createState() => _NewGroupDefinitionState();
}

class _NewGroupDefinitionState extends State<NewGroupDefinition> {
  List<String> membersFirstNameList = [];

  Future<void> memebersFirstName() async {
    List<String> fetchedNames = await getUserNames(widget.members);
    setState(() {
      membersFirstNameList = fetchedNames;
    });
  }

  bool groupSettings = true;

  bool sendMessages = true;

  bool addOtherMembers = true;
  String currentUser = '';
  List<String> admins = [];

  TextEditingController _groupName = TextEditingController();

  Future<void> fetchCurrentUser() async {
    String user = await getCurrentUser(); // Wait for the value
    setState(() {
      currentUser = user; // Update state
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    memebersFirstName();
    setState(() {
      admins.add(widget.createdBy.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'New  Group',
          style: TextStyle(fontFamily: 'Raleway', color: Colors.black),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: kIsWeb?width*0.015:  width * 0.048),
          child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/newGroup",
                    arguments: {'currentUser': widget.createdBy});
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
        ),
        backgroundColor:Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: kIsWeb?width*0.02:  width * 0.042, vertical: kIsWeb?height*0.035:  height * 0.032),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Group Name Section
            Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center, // Align items properly
            children: [
              CircleAvatar(
                radius: kIsWeb ? width * 0.027 : width * 0.066,
                backgroundColor: Color.fromRGBO(21, 171, 97, 1),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: kIsWeb ? width * 0.02 : width * 0.06,
                ),
              ),
             SizedBox(width: width * 0.015), // Add spacing only on mobile
              Expanded(
                child: TextFormField(
                  cursorColor: Colors.grey,
                  controller: _groupName,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Group Name',
                  ),
                  style: TextStyle(
                    fontSize:kIsWeb ? width * 0.015 : width * 0.05,
                    fontFamily: 'Raleway',
                    color: Colors.black,
                  ),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter Group Name';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ],
          ),

              SizedBox(height: kIsWeb?height*0.03:  height * 0.02),
              Divider(
                height: height * 0.012,
                color: Colors.grey.shade100,
                thickness:width * 0.005,
              ),
              SizedBox(
                height: height * 0.012,
              ),
              // Permissions Section
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:kIsWeb? width*0.012:   width * 0.032, vertical: height * 0.012),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Disappearing messages ',
                            style: TextStyle(
                              fontSize: kIsWeb ? width * 0.012 :  width * 0.042,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () {
                                print(
                                    "Not implemented disappearing messages yet!");
                              },
                              icon: Icon(
                                Icons.timer,
                                color: Colors.grey,
                                size:kIsWeb ? width * 0.015 :  width * 0.06,
                              ))
                        ],
                      ),
                      Text(
                        'Off',
                        style: TextStyle(
                          fontSize: kIsWeb ? width * 0.01 : width * 0.03,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.014,
                      ),
                      Row(
                        children: [
                          Text(
                            'Group Permissions',
                            style: TextStyle(
                              fontSize:  kIsWeb ? width * 0.012 :width * 0.042,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () async {
                                final result =
                                    await Navigator.of(context).pushNamed(
                                  '/groupPermissions',
                                  arguments: {
                                    'groupSettings': groupSettings,
                                    'sendMessages': sendMessages,
                                    'addOtherMembers': addOtherMembers,
                                    'admins': admins,
                                    'members': widget.members,
                                    'currentUser': widget.createdBy.uid,

                                  },
                                );

                                if (result != null) {
                                  final data = result as Map<String, dynamic>;
                                  setState(() {
                                    groupSettings = data['groupSettings'];
                                    sendMessages = data['sendMessages'];
                                    addOtherMembers = data['addOtherMembers'];
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.settings,
                                color: Colors.grey,
                                size:kIsWeb ? width * 0.015 :width * 0.06,
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Divider(
                height: height * 0.01,
                color: Colors.grey.shade100,
                thickness: width * 0.005,
              ),
              // Member Count Section
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:kIsWeb?width*0.012:   width * 0.032, vertical: height * 0.012),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Members : ${widget.members.length}',
                      style: TextStyle(
                        fontSize:  kIsWeb ? width * 0.012 : width * 0.035,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              // Member Profiles Section
              Container(
                height: height * 0.3, // Adjusted height for members list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: membersFirstNameList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(

                            backgroundColor:Color.fromRGBO(207, 214, 220, 1),
                            radius: kIsWeb?width*0.027 :  width * 0.1,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            membersFirstNameList[index],
                            style: TextStyle(
                              fontSize: kIsWeb ? width * 0.012 : width * 0.04,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_groupName.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Enter Group Name",
                style: TextStyle(fontFamily: 'Raleway', color: Colors.white),
              ),
              backgroundColor: Colors.red.shade300,
            ));
          } else {
            try {
              Group? newGroup = await createNewGroup(
                  _groupName.text.trim(),
                  "assets/images/images.jpg",
                  "Group Description",
                  widget.createdBy.uid,
                  widget.members,
                  [widget.createdBy.uid],
                  groupSettings,
                  sendMessages,
                  addOtherMembers);

              if (newGroup != null) {
                Navigator.of(context).pushNamed(
                  '/groupchat',
                  arguments: {
                    'currentUser': currentUser,
                    'groupId': newGroup.groupId,
                  },
                )
                    .catchError((error) {
                  print(error.toString());
                });
                //Adding group id to user and participants
                widget.createdBy
                    .addGroupAndAddActiveGroup(newGroup.groupId!, true);
                print(widget.members.length);
                for (var singleMember in widget.members) {
                  print(singleMember);
                  if (singleMember == widget.createdBy.uid) {
                    print(
                        'Here adding trur to group admin for person who created the group');
                    addGroupAndAddActiveGroupInDatabase(
                        newGroup.groupId!, singleMember, true);
                  } else {
                    addGroupAndAddActiveGroupInDatabase(
                        newGroup.groupId!, singleMember, false);
                  }

                  //   addGroupAndAddActiveGroupInDatabase(groupId: newGroup.groupId!, path: singleMember,isAdmin:false);
                }

                print("Group created successfully: ${newGroup.groupId}");
                // widget.members.clear();
                _groupName.clear();
              } else {
                print("Group creation failed.");
              }
            } catch (e, stackTrace) {
              print("Unexpected error: $e");
              print("StackTrace: $stackTrace");
            }
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
