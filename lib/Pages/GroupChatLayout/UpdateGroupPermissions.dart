import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/users_services.dart';

class UpdateGroupPermissions extends StatefulWidget {
  bool groupSettings;
  bool sendMessages;
  bool addOtherMembers;
  List<String> admins;
  final String currentUser;
  List<String> members;
  String createdBy;

  UpdateGroupPermissions({
    super.key,
    required this.groupSettings,
    required this.sendMessages,
    required this.addOtherMembers,
    required this.admins,
    required this.members,
    required this.currentUser,
    required this.createdBy,
  });

  @override
  State<UpdateGroupPermissions> createState() => _UpdateGroupPermissionsState();
}

class _UpdateGroupPermissionsState extends State<UpdateGroupPermissions> {
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

    final switchScale = kIsWeb ?  0.8 : 0.7;


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

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
              "addOtherMembers": widget.addOtherMembers,
              "admins": widget.admins
            });
          },
          icon: Padding(
          padding: EdgeInsets.only(left: leftHorizontalPadding),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: iconSize,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Container(
            width: kIsWeb ? width  : width,

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
                  subtitle: "This includes the name, icon, description, disappearing message timer, and the ability to pin, keep or unkeep messages",
                  value: widget.groupSettings,
                  onChanged: (val) => setState(() => widget.groupSettings = !widget.groupSettings),
                  iconSize: iconSize,
                  titleSize: contentSize,
                  subtitleSize: descriptionSize,
                  switchScale: switchScale,
                ),
                _buildPermissionItem(
                  icon: Icons.message_outlined,
                  title: "Send messages",
                  value: widget.sendMessages,
                  onChanged: (val) => setState(() => widget.sendMessages = !widget.sendMessages),
                  iconSize: iconSize,
                  titleSize: contentSize,
                  subtitleSize: descriptionSize,
                  switchScale: switchScale,
                ),
                _buildPermissionItem(
                  icon: Icons.person_add_outlined,
                  title: "Add other members",
                  value: widget.addOtherMembers,
                  onChanged: (val) => setState(() => widget.addOtherMembers = !widget.addOtherMembers),
                  iconSize: iconSize,
                  titleSize: contentSize,
                  subtitleSize: descriptionSize,
                  switchScale: switchScale,
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
                  subtitle: "When turned on, admins must approve anyone who wants to join the group",
                  value: false,
                  onChanged: null,
                  iconSize: iconSize,
                  titleSize: contentSize,
                  subtitleSize: descriptionSize,
                  switchScale: switchScale,
                ),
                SizedBox(height: height * 0.03),
                Text(
                  "Group admins:",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: headerSize,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  leading: Icon(
                    Icons.group_add_outlined,
                    size: iconSize,
                    color: Colors.black54,
                  ),
                  title: Text(
                    "Edit group admins",
                    style: TextStyle(fontSize: contentSize),
                  ),
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GroupMembers(
                          groupMembers: widget.members,
                          admins: widget.admins,
                          currentUser: widget.currentUser,
                          createdBy: widget.createdBy,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() => widget.admins = result);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
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
    required double switchScale,
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
            scale: switchScale,
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

class GroupMembers extends StatefulWidget {
  final List<String> groupMembers;
  final List<String> admins;
  final String currentUser;
  final String createdBy;

  const GroupMembers({
    super.key,
    required this.groupMembers,
    required this.admins,
    required this.currentUser,
    required this.createdBy,
  });

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  List<String> membersFirstNameList = [];
  bool isLoading = true;

  bool isCurrentUserAdmin(String userId) => widget.admins.contains(userId);

  Future<void> membersFirstName() async {
    List<String> participants = widget.groupMembers.map((e) => e.toString()).toList();
    List<String> fetchedNames = await getUserNames(participants);
    setState(() {
      membersFirstNameList = fetchedNames;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    membersFirstName();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final titleSize = kIsWeb ? width * 0.015 : 20.0;
    final contentSize = kIsWeb ? width * 0.012 : 16.0;
    final iconSize = kIsWeb ? width * 0.015 : 24.0;
    final avatarSize = kIsWeb ? width * 0.03 : width * 0.05;
    final checkIconSize = kIsWeb ? width * 0.016 : width * 0.035;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(widget.admins),
          icon: Padding(
            padding:  EdgeInsets.only(left: kIsWeb?width*0.015:  width * 0.034),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: iconSize,
            ),
          ),
        ),
        title: Text(
          "Edit Admin",
          style: TextStyle(
            color: Colors.black,
            fontSize: titleSize,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: kIsWeb?width*0.006:  width*0.012),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admins:",
                  style: TextStyle(
                    fontSize: contentSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      color: Colors.grey,
                    ),
                  )
                else
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: membersFirstNameList.length,
                    itemBuilder: (context, index) => _buildMemberTile(
                      index: index,
                      name: membersFirstNameList[index],
                      avatarSize: avatarSize,
                      checkIconSize: checkIconSize,
                      contentSize: contentSize,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required int index,
    required String name,
    required double avatarSize,
    required double checkIconSize,
    required double contentSize,
  }) {
    final isAdmin = isCurrentUserAdmin(widget.groupMembers[index]);
    final isCreator = widget.createdBy == widget.groupMembers[index];
    final isCurrentUser = widget.currentUser == widget.groupMembers[index];

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 2,horizontal:0),
      onTap: () {
        if (!isAdmin) {
          setState(() => widget.admins.add(widget.groupMembers[index]));
        } else if (!isCurrentUser && !isCreator) {
          setState(() => widget.admins.remove(widget.groupMembers[index]));
        } else if (isCreator) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You can't remove the group creator as admin"),
              backgroundColor: Colors.red.shade200,
            ),
          );
        }
      },
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF15AB61),
                width: 1,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: avatarSize,
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(color: Color(0xFF15AB61)),
              ),
            ),
          ),
          if (isAdmin)
            Positioned(
              right:kIsWeb?3:  -2,
              bottom: -2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: checkIconSize,
                  color: Color(0xFF15AB61),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: contentSize),
      ),
      trailing: isAdmin
          ? Container(
        decoration: BoxDecoration(
          color: Color(0xFFD9FCD2),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          "Admin",
          style: TextStyle(
            fontSize: contentSize * 0.8,
            color: Color(0xFF225931),
          ),
        ),
      )
          : null,
    );
  }
}