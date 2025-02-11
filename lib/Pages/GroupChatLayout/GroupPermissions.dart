import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GroupPermissions extends StatefulWidget {
  bool groupSettings;
  bool sendMessages;
  bool addOtherMembers;
  List<String> admins;
  final String currentUser;

  List<String> members;

  GroupPermissions({
    super.key,
    required this.groupSettings,
    required this.sendMessages,
    required this.addOtherMembers,
    required this.admins,
    required this.members,
    required this.currentUser
  });

  @override
  State<GroupPermissions> createState() => _GroupPermissionsState();
}

class _GroupPermissionsState extends State<GroupPermissions> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final titleSize = kIsWeb ? width * 0.015 : 20.0;

    final headerSize = kIsWeb ? width * 0.013 : 14.0;
    final contentSize = kIsWeb ? width * 0.012 : 16.0;
    final descriptionSize = kIsWeb ? width * 0.01 : 14.0;

    final iconSize = kIsWeb ? width * 0.015 : 24.0;

    final horizontalPadding = kIsWeb ? width * 0.02 : 22.0;
    final leftHorizontalPadding=     kIsWeb?width*0.015:  width * 0.034;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Group permissions",
          style: TextStyle(
            color: Colors.black,
            fontSize: titleSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop({
              'groupSettings': widget.groupSettings,
              "sendMessages": widget.sendMessages,
              "addOtherMembers": widget.addOtherMembers
            });
          },
          icon: Padding(
            padding:  EdgeInsets.only(left: leftHorizontalPadding),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: iconSize,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Container(
              width: kIsWeb ? width * 0.5 : width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Members can:",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: headerSize,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  _buildPermissionItem(
                    icon: Icons.edit_outlined,
                    title: "Edit group settings",
                    subtitle: "This includes the name, icon, description, disappearing message timer, and the ability to pin, keep or unkeep messages.",
                    value: widget.groupSettings,
                    onChanged: (val) {
                      setState(() {
                        widget.groupSettings = val;
                      });
                    },
                    iconSize: iconSize,
                    titleSize: contentSize,
                    subtitleSize: descriptionSize,
                  ),
                  _buildPermissionItem(
                    icon: Icons.message_outlined,
                    title: "Send messages",
                    value: widget.sendMessages,
                    onChanged: (val) {
                      setState(() {
                        widget.sendMessages = val;
                      });
                    },
                    iconSize: iconSize,
                    titleSize: contentSize,
                    subtitleSize: descriptionSize,
                  ),
                  _buildPermissionItem(
                    icon: Icons.person_add_outlined,
                    title: "Add other members",
                    value: widget.addOtherMembers,
                    onChanged: (val) {
                      setState(() {
                        widget.addOtherMembers = val;
                      });
                    },
                    iconSize: iconSize,
                    titleSize: contentSize,
                    subtitleSize: descriptionSize,
                  ),
                  SizedBox(height: height * 0.03),
                  Text(
                    "Admins can:",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: headerSize,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  _buildPermissionItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: "Approve new members",
                    subtitle: "When turned on, admins must approve anyone who wants to join the group.",
                    value: false,
                    onChanged: null,
                    iconSize: iconSize,
                    titleSize: contentSize,
                    subtitleSize: descriptionSize,
                  ),
                  SizedBox(height: height * 0.03),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool)? onChanged,
    required double iconSize,
    required double titleSize,
    required double subtitleSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: Colors.black54,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Transform.scale(
            scale: kIsWeb ? 0.8 : .7,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Color(0xFF15AB61),
            ),
          ),
        ],
      ),
    );
  }
}