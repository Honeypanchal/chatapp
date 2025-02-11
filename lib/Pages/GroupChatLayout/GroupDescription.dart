import 'dart:async';

import 'package:chatapp/models/CustomClass.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chatapp/services/users_services.dart';
import 'package:chatapp/services/groupChat_services.dart';

import '../../services/auth_services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GroupDescription extends StatefulWidget {
  final String groupId;
  final String currentUser;

  const GroupDescription(
      {super.key, required this.groupId, required this.currentUser});

  @override
  State<GroupDescription> createState() => _GroupDescriptionState();
}

class _GroupDescriptionState extends State<GroupDescription> {
  String firstName = '';
  String groupDescription = '';
  String groupName = '';
  dynamic group;
  bool groupSettings = true;
  bool sendMessages = true;
  bool addOtherMembers = true;

  List<String> membersFirstNameList = [];
  List<String> participants = [];
  List<String> admins = [];
  bool isLoading = true;
  bool isLoadingDatabse = true;
  late CustomClass user;

  TextEditingController _searchText = TextEditingController();
  bool _isSearching = false;

  StreamSubscription? _groupSubscription;

  void listenToDatabaseUpdates() {
    final groupRef =
        FirebaseFirestore.instance.collection("groups").doc(group['groupId']);

    _groupSubscription = groupRef.snapshots().listen((snapshot) async {
      print("Listening to changes");

      if (snapshot.exists && mounted) {
        var updatedGroupData = snapshot.data() as Map<String, dynamic>;

        setState(() {
          isLoading = true;
          isLoadingDatabse = true;
        });

        await Future.delayed(Duration(seconds: 2));

        if (mounted) {
          setState(() {
            group = updatedGroupData;
            participants = (group['participants'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
            admins = (group['admins'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
            groupSettings = group['groupSettings'];
            sendMessages = group['sendMessages'];
            addOtherMembers = group['addOtherMembers'];
            isLoading = false;
            isLoadingDatabse = false;
          });

          await membersFirstName();
        }
      }
    });
  }

  Future<void> getGroup() async {
    try {
      final anothergroup = await fetchGroupByGroupId(widget.groupId);
      setState(() {
        group = anothergroup;
        print(group['groupId']);
      });

      if (group != null) {
        setState(() {
          groupDescription = group['groupDescription'];
          admins = (group['admins'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          groupSettings = group['groupSettings'];
          sendMessages = group['sendMessages'];
          addOtherMembers = group['addOtherMembers'];
          participants = (group['participants'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
        });

        listenToDatabaseUpdates();
        await getDataAndUpdateUI();
        await membersFirstName();
      }
    } catch (e) {
      print('Error fetching group details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isCurrentUserAdmin(String userId) {
    print('Here for the admin purposes : $userId');
    return admins.contains(userId);
  }

  Future<void> membersFirstName() async {
    print('here populating participants');

    // setState(() {
    //   participants = (group['participants'] as List<dynamic>)
    //       .map((e) => e.toString())
    //       .toList();
    //   print(participants[0]);
    // });

    List<String> fetchedNames = await getUserNames(participants);

    setState(() {
      membersFirstNameList = fetchedNames;
    });
  }

  Future<void> getDataAndUpdateUI() async {
    String enteredFirstName = await getFirstNameById(group['createdBy']);

    setState(() {
      firstName = enteredFirstName;
    });
  }

  Future<void> exitGroup(String currentUser, String groupId) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Are you sure you want to exit the group?",
                style: TextStyle(fontFamily: 'Raleway', color: Colors.black)),
            actions: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            fontFamily: 'Raleway', color: Colors.grey),
                      )),
                  TextButton(
                      onPressed: () {
                        try {
                          removeUserFromGroupParticipants(
                              widget.groupId, widget.currentUser);
                          removeGroupFromCurrentUser(
                                  widget.currentUser, widget.groupId)
                              .then((_) {
                            Navigator.of(context).pushNamed('/groupDisplay',
                                arguments: {'currentUser': user});
                          });
                        } catch (e) {
                          print(e.toString());
                        }
                      },
                      child: Text(
                        "Exit",
                        style:
                            TextStyle(fontFamily: 'Raleway', color: Colors.red),
                      ))
                ],
              ),
            ],
          );
        });
  }

  void getCurrentUserDetails() async {
    CustomClass? found = await getUserDetails(widget.currentUser);
    if (found != null) {
      setState(() {
        user = found;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();

    getGroup();
  }

  Future<String?> _showGroupDescriptionModal() async {
    TextEditingController descriptionController = TextEditingController();
    descriptionController.text = group['groupDescription'] ?? "";

    return await showModalBottomSheet<String?>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;

        return Container(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(screenWidth * 0.05),
          height: screenHeight * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Group Description",
                style: TextStyle(
                    fontSize: kIsWeb ? screenWidth * 0.02 : screenWidth * 0.05),
              ),
              SizedBox(
                  height: kIsWeb ? screenHeight * 0.009 : screenHeight * 0.015),
              TextFormField(
                cursorColor: Colors.grey,
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText:
                      group['groupDescription'] ?? "Add group description",
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "The group description is visible to members of this group and people invited to this group.",
                style: TextStyle(
                    fontSize: kIsWeb ? screenWidth * 0.01 : screenWidth * 0.04,
                    color: Colors.grey),
              ),
              Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: Colors.grey, width: 0),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                          child: Text("Cancel",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      Container(width: 1, color: Colors.grey),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: Colors.grey, width: 0),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            String enteredDescription =
                                descriptionController.text;
                            if (enteredDescription.isNotEmpty) {
                              print("Group Description: $enteredDescription");
                              Navigator.pop(context, enteredDescription);
                            }
                          },
                          child:
                              Text("Ok", style: TextStyle(color: Colors.green)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showGroupNameModal() async {
    TextEditingController groupName = TextEditingController();
    groupName.text = group['groupName'] ?? "";

    return await showModalBottomSheet<String?>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;

        return Container(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(screenWidth * 0.05),
          height: screenHeight * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Group Name",
                style: TextStyle(
                    fontSize: kIsWeb ? screenWidth * 0.02 : screenWidth * 0.05),
              ),
              SizedBox(
                  height: kIsWeb ? screenHeight * 0.009 : screenHeight * 0.015),
              TextFormField(
                cursorColor: Colors.grey,
                controller: groupName,
                decoration: InputDecoration(
                  hintText: group['groupName'] ?? "Change group name",
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "The group Name is visible to members of this group and people invited to this group.",
                style: TextStyle(
                    fontSize: kIsWeb ? screenWidth * 0.01 : screenWidth * 0.04,
                    color: Colors.grey),
              ),
              Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: Colors.grey, width: 0),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            Navigator.pop(
                                context, null); // Return null if canceled
                          },
                          child: Text("Cancel",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      Container(width: 1, color: Colors.grey),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                                side: BorderSide(color: Colors.grey, width: 0)),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            String enteredName = groupName.text;
                            if (enteredName.isNotEmpty) {
                              print("Group Description: $enteredName");

                              Navigator.pop(context,
                                  enteredName); // Return the entered description
                            }
                          },
                          child:
                              Text("OK", style: TextStyle(color: Colors.green)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> changeGroupName() async {
    String? name = await _showGroupNameModal();
    if (name != null) {
      try {
        await editGroupName(group['groupId'], name);
        // setState(() {
        //   group['groupDescription'] = desc;
        // });
        setState(() {
          groupName = name;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Group Name edited succesfully",
              selectionColor: Colors.white,
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(207, 214, 220, 1),
        ));
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          color: Colors.grey,
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding:
              EdgeInsets.only(left: kIsWeb ? width * 0.015 : width * 0.034),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/groupchat',
                arguments: {
                  'groupId': widget.groupId,
                  'currentUser': widget.currentUser,
                },
              );
            },
          ),
        ),
        actions: [
          Padding(
            padding:
                EdgeInsets.only(right: kIsWeb ? width * 0.015 : width * 0.024),
            child: PopupMenuButton(
              offset: Offset(0, height * 0.052),
              elevation: 2,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text("Add members"),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text("Change group name"),
                )
              ],
              color: Colors.grey.shade200,
              onSelected: (value) {
                if (value == 0) {
                  print('$addOtherMembers');
                  if (addOtherMembers || admins.contains(widget.currentUser)) {
                    Navigator.of(context).pushNamed(
                      '/addNewMembers',
                      arguments: {
                        'existingMembers':
                            List<String>.from(group['participants'] as List),
                        // Explicit conversion
                        'groupId': widget.groupId,
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("You are not the admin of this group.",
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Raleway')),
                      backgroundColor: Colors.red.shade200,
                    ));
                  }
                } else if (value == 1) {
                  if (!isCurrentUserAdmin(widget.currentUser)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("You are not the admin",
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Raleway')),
                      backgroundColor: Colors.red.shade200,
                    ));
                  } else {
                    changeGroupName();
                  }
                }
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: kIsWeb ? width * 0.05 : width * 0.13,
                backgroundColor: Color.fromRGBO(207, 214, 220, 1),
                child: Icon(Icons.group,
                    color: Colors.white,
                    size: kIsWeb ? width * 0.04 : width * 0.09),
              ),
            ),
            SizedBox(height: height * 0.012),
            Text(group['groupName'],
                style: TextStyle(
                    fontSize: kIsWeb ? width * 0.015 : width * 0.055)),
            Text('Group · ${group['participants'].length} members',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: kIsWeb ? width * 0.015 : width * 0.042)),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(Icons.wifi_calling_3_outlined, 'Audio'),
                _buildButton(Icons.video_call_outlined, 'Video'),

                //Adding a new member to the group ;
                GestureDetector(
                    onTap: () {
                      print('$addOtherMembers');
                      if (addOtherMembers ||
                          admins.contains(widget.currentUser)) {
                        Navigator.of(context).pushNamed(
                          '/addNewMembers',
                          arguments: {
                            'existingMembers': List<String>.from(
                                group['participants'] as List),
                            // Explicit conversion
                            'groupId': widget.groupId,
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("You are not the admin of this group.",
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Raleway')),
                          backgroundColor: Colors.red.shade200,
                        ));
                      }
                    },
                    child: _buildButton(Icons.person_add_alt, 'Add')),
                _buildButton(Icons.search, 'Search'),
              ],
            ),
            SizedBox(height: height * 0.012),
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            SizedBox(height: height * 0.012),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: kIsWeb ? width * 0.02 : width * 0.057,
                  vertical: height * 0.017),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (!isCurrentUserAdmin(widget.currentUser)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("You are not the admin",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Raleway')),
                            backgroundColor: Colors.red.shade200,
                          ));
                        } else {
                          String? desc = await _showGroupDescriptionModal();
                          if (desc != null) {
                            try {
                              await editGroupInfo(group['groupId'], desc);
                              // setState(() {
                              //   group['groupDescription'] = desc;
                              // });
                              setState(() {
                                groupDescription = desc;
                              });

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  "Group description edited succesfully",
                                  selectionColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    Color.fromRGBO(207, 214, 220, 1),
                              ));
                            } catch (e) {
                              print(e.toString());
                            }
                          }
                        }
                      },
                      child: Text(
                        groupDescription,
                        style: TextStyle(
                            color: Color.fromRGBO(21, 171, 97, 1),
                            fontSize: kIsWeb ? width * 0.015 : width * 0.037),
                      ),
                    ),
                    SizedBox(height: height * 0.005),
                    Text(
                      'Created by ${firstName}, ${group['createdAt'].toDate().hour} : ${group['createdAt'].toDate().minute}',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            ListTile(
              leading: Icon(
                Icons.notifications_none,
                size: kIsWeb ? width * 0.015 : width * 0.06,
              ),
              title: Text(
                'Notifications',
                style:
                    TextStyle(fontSize: kIsWeb ? width * 0.015 : width * 0.045),
              ),
              trailing: Icon(
                Icons.chevron_right,
                size: kIsWeb ? width * 0.015 : width * 0.07,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.image_outlined,
                size: kIsWeb ? width * 0.015 : width * 0.06,
              ),
              title: Text('Media visibility',
                  style: TextStyle(
                      fontSize: kIsWeb ? width * 0.015 : width * 0.045)),
              trailing: Icon(
                Icons.chevron_right,
                size: kIsWeb ? width * 0.015 : width * 0.07,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.star_border,
                size: kIsWeb ? width * 0.015 : width * 0.06,
                color: Colors.black,
              ),
              title: Text(
                'Starred Messages',
                style:
                    TextStyle(fontSize: kIsWeb ? width * 0.015 : width * 0.045),
              ),
              trailing: Icon(Icons.chevron_right,
                  size: kIsWeb ? width * 0.015 : width * 0.07),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          StarredMessagesPage(groupId: widget.groupId)),
                );
              },
            ),
            SizedBox(height: height * 0.012),
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            SizedBox(height: height * 0.012),
            ListTile(
              leading: Icon(
                Icons.lock_outline,
                size: kIsWeb ? width * 0.015 : width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 0 : width * 0.012),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encryption',
                      style: TextStyle(
                          fontSize: kIsWeb ? width * 0.015 : width * 0.045),
                    ),
                    Container(
                        width: width * 0.6,
                        child: Text(
                            "Messages and calls are end-to-end encrypted.",
                            style: TextStyle(
                                fontSize: kIsWeb ? width * 0.01 : width * 0.035,
                                color: Colors.grey)))
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.timer_outlined,
                size: kIsWeb ? width * 0.015 : width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 0 : width * 0.012),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disappearing messages',
                        style: TextStyle(
                            fontSize: kIsWeb ? width * 0.015 : width * 0.045)),
                    Text("off",
                        style: TextStyle(
                            fontSize: kIsWeb ? width * 0.01 : width * 0.035,
                            color: Colors.grey))
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.mail_lock_outlined,
                size: kIsWeb ? width * 0.015 : width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 0 : width * 0.012),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chat lock',
                        style: TextStyle(
                            fontSize: kIsWeb ? width * 0.015 : width * 0.045)),
                    Text("Lock and hide this chat on this device",
                        style: TextStyle(
                            fontSize: kIsWeb ? width * 0.01 : width * 0.035,
                            color: Colors.grey))
                  ],
                ),
              ),
              trailing: Padding(
                padding:
                    EdgeInsets.only(left: kIsWeb ? width * 0.03 : width * 0.1),
                child: Transform.scale(
                    scale: kIsWeb ? width * 0.0004 : width * 0.0016,
                    child: Switch(
                      value: false,
                      onChanged: (val) {},
                      activeColor: Colors.black,
                    )),
              ),
            ),
            if (isCurrentUserAdmin(widget.currentUser)) ...[
              ListTile(
                onTap: () async {
                  final result = await Navigator.of(context).pushNamed(
                    '/updateGroupPermissions',
                    arguments: {
                      'groupSettings': group['groupSettings'],
                      'sendMessages': group['sendMessages'],
                      'addOtherMembers': group['addOtherMembers'],
                      'admins': admins,
                      'members': participants,
                      'currentUser': widget.currentUser,
                      'createdBy': group['createdBy']
                    },
                  ) as Map<String, dynamic>?;
                  if (result != null) {
                    List<String> newAdmins = result['admins'];

                    setState(() {
                      admins = newAdmins;
                      sendMessages = result['sendMessages'];
                      addOtherMembers = result['addOtherMembers'];
                      groupSettings = result['groupSettings'];
                    });

                    try {
                      print("Here to update group settings");
                      print(
                          '${result['groupSettings']}, ${result['sendMessages']},${result['addOtherMembers']}');
                      updateGroupSettings(
                        group['groupId'],
                        result['groupSettings'],
                        result['sendMessages'],
                        result['addOtherMembers'],
                        admins,
                      );

                      for (String members in group['participants']) {
                        if (admins.contains(members)) {
                          print('$members is the admin');
                          updateAdminStatusForCurrentUser(
                              members, group['groupId'], true);
                        } else {
                          print('$members is  not the admin');
                          updateAdminStatusForCurrentUser(
                              members, group['groupId'], false);
                        }
                      }
                    } catch (e) {
                      print(e.toString());
                    }
                  }
                },
                leading: Icon(
                  Icons.settings,
                  size: kIsWeb ? width * 0.015 : width * 0.06,
                ),
                title: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: kIsWeb ? 0 : width * 0.012),
                  child: Text('Group permissions',
                      style: TextStyle(
                          fontSize: kIsWeb ? width * 0.015 : width * 0.045)),
                ),
              )
            ],
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            SizedBox(height: height * 0.012),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: kIsWeb?0: width * 0.035, vertical: height * 0.012),
              padding: EdgeInsets.symmetric(horizontal: width * 0.012),
              child: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${group['participants'].length} members ",
                        style: TextStyle(
                            fontSize: kIsWeb ? width * 0.015 : width * 0.042),
                      ),
                      Spacer(),
                      // Padding(
                      //   padding: EdgeInsets.only(right: width * 0.052),
                      //   child: Icon(
                      //     Icons.search,
                      //     size: width * 0.062,
                      //   ),
                      // )
                    ],
                  ),
                  SizedBox(
                    height: height * 0.012,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        ListTile(
                          //Adding new members to the group after checking if the user is the admin and the permissions
                          onTap: () {
                            print('$addOtherMembers');
                            if (addOtherMembers ||
                                admins.contains(widget.currentUser)) {
                              Navigator.of(context).pushNamed(
                                '/addNewMembers',
                                arguments: {
                                  'existingMembers': List<String>.from(
                                      group['participants'] as List),
                                  // Explicit conversion
                                  'groupId': widget.groupId,
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "You are not the admin of this group.",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Raleway')),
                                backgroundColor: Colors.red.shade200,
                              ));
                            }
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                              backgroundColor: Color.fromRGBO(21, 171, 97, 1),
                              child: Icon(
                                Icons.group_add_outlined,
                                color: Colors.white,
                                size: kIsWeb ? width * 0.015 : width * 0.052,
                              )),
                          title: Text(
                            "Add members",
                            style: TextStyle(
                                fontSize:
                                    kIsWeb ? width * 0.015 : width * 0.045),
                          ),
                        ),
                        if (isLoading || isLoadingDatabse)
                          CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            color: Colors.grey,
                          )
                        else ...[
                          Padding(
                            padding:  EdgeInsets.zero,
                            child: ListView.builder(

                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: group['participants'].length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onLongPress: () {
                                    if (widget.currentUser ==
                                        group['participants'][index]) {
                                    } else {
                                      if (isCurrentUserAdmin(
                                          widget.currentUser)) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: Text(
                                                    "Remove ${membersFirstNameList[index]} from this group?",
                                                    style: TextStyle(
                                                        fontFamily: 'Raleway',
                                                        color: Colors.black)),
                                                actions: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context)
                                                                .pop();
                                                          },
                                                          child: Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Raleway',
                                                                color:
                                                                    Colors.black),
                                                          )),
                                                      TextButton(
                                                          onPressed: () async {
                                                            try {
                                                              print(
                                                                  "The particpant you are removing is ${group['participants'][index]} their name is ${membersFirstNameList[index]}");

                                                              await removeGroupFromThisUser(
                                                                  group['participants']
                                                                      [index],
                                                                  widget.groupId);
                                                              removeUserFromThisGroup(
                                                                      widget
                                                                          .groupId,
                                                                      group['participants']
                                                                          [index])
                                                                  .then((_) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              });
                                                            } catch (e) {
                                                              print(e.toString());
                                                            }
                                                          },
                                                          child: Text(
                                                            "Remove",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Raleway',
                                                                color:
                                                                    Colors.red),
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              );
                                            });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            "You cant remove participants",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Raleway'),
                                          ),
                                          backgroundColor: Colors.red.shade200,
                                        ));
                                      }
                                    }
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Color.fromRGBO(30, 170, 97, 1),
                                    child: Text(
                                      membersFirstNameList[index][0]
                                          .toUpperCase(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(membersFirstNameList[index]),
                                  trailing: isCurrentUserAdmin(
                                          group['participants'][index])
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              right: kIsWeb
                                                  ? width * 0.01
                                                  : width * 0.026),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFD9FCD2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          child: Text(
                                            "Admin",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF225931),
                                            ),
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            SizedBox(height: height * 0.012),
            ListTile(
              leading: Icon(
                Icons.favorite_outline,
                size: kIsWeb ? width * 0.015 : width * 0.06,
              ),
              title: Text(
                'Add to Favourites',
                style:
                    TextStyle(fontSize: kIsWeb ? width * 0.015 : width * 0.045),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.people_outline,
                size: kIsWeb ? width * 0.015 : width * 0.06,
              ),
              title: Text('Add to list',
                  style: TextStyle(
                      fontSize: kIsWeb ? width * 0.015 : width * 0.045)),
            ),
            ListTile(
              onTap: () {
                exitGroup(widget.currentUser, widget.groupId);
              },
              leading: Icon(
                Icons.exit_to_app,
                size: kIsWeb ? width * 0.015 : width * 0.06,
                color: Colors.red,
              ),
              title: Text('Exit group',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: kIsWeb ? width * 0.015 : width * 0.045)),
            ),
            ListTile(
              leading: Icon(
                Icons.thumb_down_alt_outlined,
                size: kIsWeb ? width * 0.015 : width * 0.06,
                color: Colors.red,
              ),
              title: Text('Report group',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: kIsWeb ? width * 0.015 : width * 0.045)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.042, vertical: height * 0.017),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius:
                BorderRadius.circular(kIsWeb ? width * 0.02 : width * 0.032),
          ),
          child: Icon(icon, color: Color.fromRGBO(21, 171, 97, 1)),
        ),
        SizedBox(height: height * 0.01),
        Text(label),
      ],
    );
  }
}

// for starred message
class StarredMessagesPage extends StatefulWidget {
  final String groupId;

  const StarredMessagesPage({Key? key, required this.groupId})
      : super(key: key);

  @override
  _StarredMessagesPageState createState() => _StarredMessagesPageState();
}

class _StarredMessagesPageState extends State<StarredMessagesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F1EB),
      appBar: AppBar(
        title: Text("Starred Messages"),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .where('favorite', isEqualTo: true)
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              color: Colors.grey,
            ));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading messages",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No Starred Messages Yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          var messages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];

              // Ensure null safety for missing fields
              var messageText = message['message'] ?? "No text available";
              var senderName = message['sender'] ?? "Unknown Sender";
              var timestamp = message['timestamp'] != null
                  ? (message['timestamp'] as Timestamp).toDate()
                  : DateTime.now(); // Handle missing timestamps

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      senderName,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 5),
                    Text(
                      messageText,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 5),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              SizedBox(width: 3),
                              Text(
                                "${timestamp.hour}:${timestamp.minute}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ])),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
