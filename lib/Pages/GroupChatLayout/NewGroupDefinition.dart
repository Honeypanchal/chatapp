import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/models/Group.dart';
import 'package:chatapp/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/groupChat_services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const kGreen = Color(0xFF15AB61);
const kGreenLight = Color(0xFFE8F5EE);

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
  bool groupSettings = true;
  bool sendMessages = true;
  bool addOtherMembers = true;
  String currentUser = '';
  List<String> admins = [];
  final TextEditingController _groupName = TextEditingController();

  // Distinct colors for member avatars
  final List<Color> _avatarColors = [
    const Color(0xFF15AB61),
    const Color(0xFF3B82F6),
    const Color(0xFF8B5CF6),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF06B6D4),
  ];

  Future<void> _fetchMembers() async {
    List<String> names = await getUserNames(widget.members);
    setState(() => membersFirstNameList = names);
  }

  Future<void> _fetchCurrentUser() async {
    String user = await getCurrentUser();
    setState(() => currentUser = user);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchMembers();
    admins.add(widget.createdBy.uid);
  }

  @override
  void dispose() {
    _groupName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: kIsWeb ? width * 0.015 : 12),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              "/newGroup",
              arguments: {'currentUser': widget.createdBy},
            ),
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: kGreenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios,
                  size: 14, color: kGreen),
            ),
          ),
        ),
        title: const Text(
          'New Group',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? width * 0.02 : 14,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + Name Card ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: kGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 26),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: kGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.add,
                              size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GROUP NAME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _groupName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            cursorColor: kGreen,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 8),
                              hintText: 'e.g. Dev Team, Family...',
                              hintStyle: TextStyle(
                                  color: Color(0xFF666666), fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── SETTINGS label ──────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // ── Settings Card ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  // Disappearing Messages
                  _SettingRow(
                    iconBg: const Color(0xFFE8F0FE),
                    icon: Icons.access_time_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Disappearing Messages',
                    subtitle: 'Off',
                    onTap: () {},
                    showDivider: true,
                  ),
                  // Group Permissions
                  _SettingRow(
                    iconBg: const Color(0xFFF0EAFF),
                    icon: Icons.tune_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: 'Group Permissions',
                    subtitle: 'All members can send messages',
                    onTap: () async {
                      final result = await Navigator.of(context).pushNamed(
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
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── MEMBERS label + badge ───────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
              child: Row(
                children: [
                  const Text(
                    'MEMBERS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: kGreenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.members.length} added',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Members Card ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: membersFirstNameList.isEmpty
                  ? const Center(
                  child: CircularProgressIndicator(color: kGreen))
                  : Wrap(
                spacing: 14,
                runSpacing: 12,
                children: List.generate(
                  membersFirstNameList.length,
                      (index) => _MemberChip(
                    name: membersFirstNameList[index],
                    initials: _initials(membersFirstNameList[index]),
                    color: _avatarColors[index % _avatarColors.length],
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.1),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_groupName.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Enter a group name',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ));
            return;
          }
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
              addOtherMembers,
            );
            if (newGroup != null) {
              Navigator.of(context).pushNamed('/groupchat', arguments: {
                'currentUser': currentUser,
                'groupId': newGroup.groupId,
              });
              widget.createdBy
                  .addGroupAndAddActiveGroup(newGroup.groupId!, true);
              for (var member in widget.members) {
                addGroupAndAddActiveGroupInDatabase(
                  newGroup.groupId!,
                  member,
                  member == widget.createdBy.uid,
                );
              }
              _groupName.clear();
            }
          } catch (e, st) {
            debugPrint("Error: $e\n$st");
          }
        },
        backgroundColor: kGreen,
        elevation: 6,
        child: const Icon(Icons.arrow_forward_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }
}

// ── Reusable Setting Row ──────────────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingRow({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                      const SizedBox(height: 1),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Color(0xFFC7C7CC), size: 20),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
              height: 0.5, thickness: 0.5,
              indent: 64, endIndent: 0,
              color: Color(0xFFE5E5EA)),
      ],
    );
  }
}

// ── Member Chip ───────────────────────────────────────────────────────────────
class _MemberChip extends StatelessWidget {
  final String name;
  final String initials;
  final Color color;

  const _MemberChip({
    required this.name,
    required this.initials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color,
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.5)),
          ),
          const SizedBox(height: 5),
          Text(name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF555555),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}