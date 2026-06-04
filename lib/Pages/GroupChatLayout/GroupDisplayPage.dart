import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:intl/intl.dart';
import '../helpers/MainNavigation.dart';

class GroupDisplayPage extends StatefulWidget {
  final CustomClass currentUser;

  const GroupDisplayPage({super.key, required this.currentUser});

  @override
  State<GroupDisplayPage> createState() => _GroupDisplayPageState();
}

class _GroupDisplayPageState extends State<GroupDisplayPage> {
  // ─── Theme ────────────────────────────────────────────────────────────────
  static const Color kGreen       = Color(0xFF4CAF50);
  static const Color kGreenLight  = Color(0xFFF0FAF4);
  static const Color kGreenDark   = Color(0xFF2E7D32);
  static const Color kTextPrimary   = Color(0xFF111111);
  static const Color kTextSecondary = Color(0xFF888888);
  static const Color kDivider     = Color(0xFFF0F0F0);

  // ─── State ────────────────────────────────────────────────────────────────
  int _selectedIndex = 1;
  final TextEditingController _searchText = TextEditingController();
  final CollectionReference _groupsDB =
  FirebaseFirestore.instance.collection('groups');
  String _searchQuery = '';

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _searchText.addListener(() {
      setState(() => _searchQuery = _searchText.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

  // ─── Navigation ───────────────────────────────────────────────────────────
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/chatPage',
            arguments: {'currentUser': widget.currentUser});
        break;
      case 1:
        Navigator.pushNamed(context, '/groupDisplay',
            arguments: {'currentUser': widget.currentUser});
        break;
      case 2:
        Navigator.pushNamed(context, '/statusPage');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile',
            arguments: {'currentUser': widget.currentUser});
        break;
    }
  }

  // ─── Data ─────────────────────────────────────────────────────────────────
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchGroups() {
    Query query =
    _groupsDB.where('participants', arrayContains: widget.currentUser.uid);

    if (_searchQuery.isNotEmpty) {
      query = query
          .where('groupName', isGreaterThanOrEqualTo: _searchQuery)
          .where('groupName', isLessThan: '$_searchQuery\uf8fff');
    }

    return query.snapshots().map((s) =>
    s.docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>);
  }

  Future<Map<String, String>> _getLastMessage(String groupId) async {
    final snap = await _groupsDB
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final d = snap.docs.first.data();
      return {
        'sender'   : d['sender']    ?? '',
        'message'  : d['message']   ?? '',
        'timestamp': _formatTime(d['timestamp'] as Timestamp?),
      };
    }
    return {'sender': '', 'message': 'No messages yet', 'timestamp': ''};
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    try {
      final t   = ts.toDate();
      final now = DateTime.now();
      if (DateFormat('yyyy-MM-dd').format(t) ==
          DateFormat('yyyy-MM-dd').format(now)) {
        return DateFormat('HH:mm').format(t);
      }
      if (DateFormat('yyyy-MM-dd').format(t) ==
          DateFormat('yyyy-MM-dd')
              .format(now.subtract(const Duration(days: 1)))) {
        return 'Yesterday';
      }
      return DateFormat('MMM d').format(t);
    } catch (_) {
      return '';
    }
  }

  /// Deterministic color from group name
  Color _groupColor(String name) {
    const colors = [
      Color(0xFF4CAF50),
      Color(0xFF1976D2),
      Color(0xFF7B1FA2),
      Color(0xFFF57C00),
      Color(0xFF00796B),
      Color(0xFFD32F2F),
      Color(0xFF0288D1),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  /// Up-to-2-word initials for square avatar
  String _groupInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchText,
        cursorColor: kGreen,
        enableSuggestions: false,
        autocorrect: false,
        style: const TextStyle(
            fontSize: 13, color: kTextPrimary, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: 'Search groups…',
          hintStyle: TextStyle(
              fontSize: 13,
              color: kTextSecondary.withOpacity(0.7),
              fontFamily: 'Poppins'),
          prefixIcon: Icon(Icons.search_rounded,
              color: kTextSecondary.withOpacity(0.6), size: 20),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: kGreenLight, shape: BoxShape.circle),
            child: const Icon(Icons.group_outlined,
                color: kGreen, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No groups yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Text('Tap + to create a new group',
              style: TextStyle(
                  fontSize: 13,
                  color: kTextSecondary,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> groupData) {
    final groupId   = groupData['groupId'] as String? ?? '';
    final groupName = groupData['groupName'] as String? ?? 'Unnamed Group';
    final members   = (groupData['participants'] as List?)?.length ?? 0;

    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            '/groupchat',
            arguments: {
              'groupId'    : groupId,
              'currentUser': widget.currentUser.uid,
            },
          ),
          splashColor: kGreenLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Rounded-square avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _groupColor(groupName),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _groupInitials(groupName),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                    // Member count badge
                    if (members > 0)
                      Positioned(
                        bottom: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kGreen, width: 1.5),
                          ),
                          child: Text(
                            '$members',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: kGreenDark),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // Content driven by FutureBuilder
                Expanded(
                  child: FutureBuilder<Map<String, String>>(
                    future: _getLastMessage(groupId),
                    builder: (context, snap) {
                      final sender  = snap.data?['sender']    ?? '';
                      final message = snap.data?['message']   ?? '';
                      final time    = snap.data?['timestamp'] ?? '';

                      final preview = sender.isNotEmpty
                          ? '$sender: $message'
                          : message;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  groupName,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: kTextPrimary,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                              if (time.isNotEmpty)
                                Text(
                                  time,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: kTextSecondary,
                                      fontFamily: 'Poppins'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            preview.isNotEmpty ? preview : 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: kTextSecondary,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Indented divider
        Padding(
          padding: const EdgeInsets.only(left: 78),
          child: Divider(height: 0.5, thickness: 0.5, color: kDivider),
        ),
      ],
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Groups',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              fontFamily: 'Poppins'),
        ),
        actions: [
          // Create group shortcut
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/newGroup',
              arguments: {'currentUser': widget.currentUser},
            ),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                  color: kGreenLight, shape: BoxShape.circle),
              child: const Icon(Icons.group_add_outlined,
                  color: kGreen, size: 18),
            ),
          ),
          // More menu
          PopupMenuButton<int>(
            padding: EdgeInsets.zero,
            icon: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 16),
              decoration: const BoxDecoration(
                  color: kGreenLight, shape: BoxShape.circle),
              child: const Icon(Icons.more_horiz_rounded,
                  color: kGreen, size: 20),
            ),
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 0,
                child: Row(children: [
                  const Icon(Icons.star_outline_rounded,
                      color: kGreen, size: 18),
                  const SizedBox(width: 10),
                  Text('Starred Messages',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(children: [
                  const Icon(Icons.group_add_outlined,
                      color: kGreen, size: 18),
                  const SizedBox(width: 10),
                  Text('Create a Group',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
            onSelected: (val) {
              if (val == 0) {
                Navigator.pushNamed(context, '/starredMessages',
                    arguments: {'currentUser': widget.currentUser});
              } else {
                Navigator.pushNamed(context, '/newGroup',
                    arguments: {'currentUser': widget.currentUser});
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'YOUR GROUPS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFAAAAAA),
                  letterSpacing: 1.2,
                  fontFamily: 'Poppins'),
            ),
          ),
          Expanded(
            child: StreamBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _fetchGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(kGreen)));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error fetching groups',
                          style: TextStyle(
                              color: kTextSecondary,
                              fontFamily: 'Poppins')));
                }
                final groups = snapshot.data ?? [];
                if (groups.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (_, i) =>
                      _buildGroupTile(groups[i].data()),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: MainNavigationPage(
          currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}