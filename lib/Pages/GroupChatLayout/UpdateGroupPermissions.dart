import 'package:flutter/material.dart';

import '../../services/users_services.dart';

class UpdateGroupPermissions extends StatefulWidget {
  bool groupSettings;

  bool sendMessages;

  bool addOtherMembers;
  List<String> admins;
  final String currentUser;
  List<String> members;
  String createdBy;

  UpdateGroupPermissions(
      {super.key,
      required this.groupSettings,
      required this.sendMessages,
      required this.addOtherMembers,
      required this.admins,
      required this.members,
      required this.currentUser,
      required this.createdBy});

  @override
  State<UpdateGroupPermissions> createState() => _UpdateGroupPermissionsState();
}

class _UpdateGroupPermissionsState extends State<UpdateGroupPermissions> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Group permissions",
          style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: width * 0.052,
              color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop({
                'groupSettings': widget.groupSettings,
                "sendMessages": widget.sendMessages,
                "addOtherMembers": widget.addOtherMembers,
                "admins": widget.admins
              });
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: width,
          height: height,
          margin: EdgeInsets.symmetric(
              horizontal: width * 0.032, vertical: height * 0.032),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.012, vertical: height * 0.012),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                    opacity: 0.5,
                    child: Text(
                      "Members can : ",
                      style: TextStyle(
                        fontSize: width * 0.042,
                      ),
                    )),
                SizedBox(
                  height: height * 0.012,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.edit_outlined,
                          size: width * 0.054,
                        )),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Edit group settings",
                            style: TextStyle(fontSize: width * 0.04),
                          ),
                          Container(
                            width: width * 0.6,
                            child: Text(
                              "This includes the name, icon , description , disappearing message timer, and the ability to pin , keep or unkeep messages ",
                              style: TextStyle(
                                  fontSize: width * 0.03, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Transform.scale(
                        scale: width * 0.002,
                        child: Switch(
                            activeColor: Colors.green.shade700,
                            focusColor: Colors.green.shade700,
                            value: widget.groupSettings,
                            onChanged: (val) {
                              setState(() {
                                widget.groupSettings = !widget.groupSettings;
                              });
                            }),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.035,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.message,
                          size: width * 0.054,
                        )),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Send messages",
                        style: TextStyle(fontSize: width * 0.04),
                      ),
                    ),
                    Expanded(
                      child: Transform.scale(
                        scale: width * 0.002,
                        child: Switch(
                            activeColor: Colors.green.shade700,
                            focusColor: Colors.green.shade700,
                            value: widget.sendMessages,
                            onChanged: (val) {
                              setState(() {
                                widget.sendMessages = !widget.sendMessages;
                              });
                            }),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.035,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.group_add_outlined,
                          size: width * 0.054,
                        )),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Add Other members",
                        style: TextStyle(fontSize: width * 0.04),
                      ),
                    ),
                    Expanded(
                      child: Transform.scale(
                        scale: width * 0.002,
                        child: Switch(
                            activeColor: Colors.green.shade700,
                            focusColor: Colors.green.shade700,
                            value: widget.addOtherMembers,
                            onChanged: (val) {
                              setState(() {
                                widget.addOtherMembers =
                                    !widget.addOtherMembers;
                              });
                            }),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.012,
                ),
                Opacity(
                    opacity: 0.5,
                    child: Text(
                      "Admins can  : ",
                      style: TextStyle(
                        fontSize: width * 0.042,
                      ),
                    )),
                SizedBox(
                  height: height * 0.012,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.perm_identity_sharp,
                          size: width * 0.054,
                        )),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Approve new members",
                            style: TextStyle(fontSize: width * 0.04),
                          ),
                          Container(
                            width: width * 0.47,
                            child: Text(
                              "When turned on , admins must approve anyone who wants to join the group .",
                              style: TextStyle(
                                  fontSize: width * 0.03, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Transform.scale(
                            scale: width * 0.002,
                            child: Switch(value: false, onChanged: (val) {})))
                  ],
                ),
                SizedBox(
                  height: height * 0.012,
                ),
                Opacity(
                    opacity: 0.5,
                    child: Text(
                      "Group admins : ",
                      style: TextStyle(
                        fontSize: width * 0.042,
                      ),
                    )),
                ListTile(
                  onTap: () async {
                    var result = widget.admins = await Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => GroupMembers(
                                groupMembers: widget.members,
                                admins: widget.admins,
                                currentUser: widget.currentUser,createdBy: widget.createdBy,)));
                    if (result != null) {
                      setState(() {
                        widget.admins = result;
                        print(
                            '${widget.admins.length} is the length of admins');
                      });
                    }
                  },
                  leading: Icon(
                    Icons.group_add_outlined,
                    size: width * 0.054,
                  ),
                  title: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.012, vertical: height * 0.012),
                    child: Padding(
                      padding: EdgeInsets.only(left: width * 0.012),
                      child: Text("Edit group admins"),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GroupMembers extends StatefulWidget {
  final List<String> groupMembers;
  final List<String> admins;
  final String currentUser;
  final String createdBy;

  const GroupMembers(
      {super.key,
      required this.groupMembers,
      required this.admins,
      required this.currentUser,
      required this.createdBy});

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  List<String> membersFirstNameList = [];
  bool isLoading = true;

  bool isCurrentUserAdmin(String userId) {
    return widget.admins.contains(userId);
  }

  Future<void> memebersFirstName() async {
    print(widget.groupMembers);

    List<String> participants = (widget.groupMembers as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    List<String> fetchedNames = await getUserNames(participants);

    setState(() {
      membersFirstNameList = fetchedNames;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    memebersFirstName();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(widget.admins);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text(
          "Edit Admin",
          style: TextStyle(color: Colors.white, fontFamily: 'Raleway'),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.052, vertical: height * 0.032),
          child: Column(
            children: [
              Row(
                children: [
                  Text("Admins :"),
                ],
              ),
              if (isLoading)
                CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  color: Colors.green.shade700,
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: membersFirstNameList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      if (!widget.admins.contains(widget.groupMembers[index])) {
                        setState(() {
                          widget.admins.add(widget.groupMembers[index]);
                        });
                      } else {
                        setState(() {
                          if (widget.currentUser ==
                              widget.groupMembers[index]) {
                          } else {
                            if (widget.createdBy ==
                                widget.groupMembers[index]) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "You cant remove them as the admin as theyve created the group"),
                                backgroundColor: Colors.red.shade200,
                              ));
                              ;
                            }else
                              {   widget.admins.remove(widget.groupMembers[index]);}



                          }
                        });
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: width * 0.05,
                          child: Text(
                            membersFirstNameList[index][0].toUpperCase(),
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ),
                        if (isCurrentUserAdmin(widget.groupMembers[index]))
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
                    title: Text(membersFirstNameList[index]),
                    trailing: isCurrentUserAdmin(widget.groupMembers[index])
                        ? Container(
                            decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                border:
                                    Border.all(color: Colors.green.shade700),
                                borderRadius:
                                    BorderRadius.circular(width * 0.01)),
                            width: width * 0.12,
                            height: height * 0.017,
                            child: Center(
                              child: Text(
                                "Admin",
                                style: TextStyle(
                                    fontSize: width * 0.027,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
