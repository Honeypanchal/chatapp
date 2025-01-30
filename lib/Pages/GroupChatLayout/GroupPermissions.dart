import 'package:flutter/material.dart';

class Grouppermissions extends StatefulWidget {
  bool groupSettings;

  bool sendMessages;

  bool addOtherMembers;


  Grouppermissions(
      {super.key,
      required this.groupSettings,required this.sendMessages,

        required this.addOtherMembers,

      });

  @override
  State<Grouppermissions> createState() => _GrouppermissionsState();
}

class _GrouppermissionsState extends State<Grouppermissions> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
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
                'groupSettings':widget.groupSettings,
                "sendMessages":widget.sendMessages,
                "addOtherMembers":widget.addOtherMembers
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
                            activeColor: Colors.blue[600],
                            focusColor: Colors.blue[600],
                            value: widget.groupSettings,
                            onChanged: (val) {
                        setState(() {
                          widget.groupSettings=!widget.groupSettings;
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
                            activeColor: Colors.blue[600],
                            focusColor: Colors.blue[600],
                            value: widget.sendMessages,
                            onChanged: (val) {
                         setState(() {
                           widget.sendMessages=!widget.sendMessages;
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
                            activeColor: Colors.blue[600],
                            focusColor: Colors.blue[600],
                            value: widget.addOtherMembers,
                            onChanged: (val) {
                           setState(() {
                             widget.addOtherMembers=!widget.addOtherMembers;
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
