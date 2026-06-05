import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chatlayout/chat_layout.dart';
import 'package:chatapp/Pages/Chatlayout/user_list.dart';
import 'package:chatapp/pages/helpers/MainNavigation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final CustomClass currentUser;



  const ChatPage({super.key, required this.currentUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // ─── Theme ────────────────────────────────────────────────────────────────
  static const Color kGreen      = Color(0xFF4CAF50);
  static const Color kGreenLight = Color(0xFFF0FAF4);
  static const Color kTextPrimary   = Color(0xFF111111);
  static const Color kTextSecondary = Color(0xFF888888);
  static const Color kDivider    = Color(0xFFF0F0F0);
  static const Color kBg         = Color(0xFFF6F8F6);

  // ─── State ────────────────────────────────────────────────────────────────
  final _database = FirebaseFirestore.instance.collection('Users');
  final dynamic _chatsDB = FirebaseFirestore.instance.collection('chats');

  List<Map<String, dynamic>> _selectedUsers  = [];
  List<Map<String, dynamic>> _filteredUsers  = [];
  bool _isLoading = false;
  int  _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadSelectedUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
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

  Future<void> _loadSelectedUsers() async {
    setState(() => _isLoading = true);
    final doc = await _database.doc(widget.currentUser.uid).get();
    if (doc.exists && doc.data() != null) {
      final saved = List<Map<String, dynamic>>.from(doc.get('selectedUsers') ?? []);
      setState(() {
        _selectedUsers  = saved;
        _filteredUsers  = saved;
        _isLoading      = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _selectedUsers
          .where((u) => (u['firstName'] as String).toLowerCase().contains(q))
          .toList();
    });
  }

  void _navigateToChat(Map<String, dynamic> user) {
    final docId = widget.currentUser.uid.compareTo(user['uid']) < 0
        ? '${widget.currentUser.uid}_${user['uid']}'
        : '${user['uid']}_${widget.currentUser.uid}';

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatLayout(
        currentUser: widget.currentUser,
        user: user,
        databaseRef: _chatsDB.doc(docId),
      ),
    ));
  }

  Future<Map<String, dynamic>> _getLastMessage(String groupId) async {
    final snap = await _chatsDB
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final d = snap.docs.first.data();
      return {'message': d['message'] ?? '', 'timestamp': d['timestamp']};
    }
    return {'message': 'No messages yet', 'timestamp': null};
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final t   = ts.toDate();
    final now = DateTime.now();
    if (DateFormat('yyyy-MM-dd').format(t) == DateFormat('yyyy-MM-dd').format(now)) {
      return DateFormat('HH:mm').format(t);
    }
    if (DateFormat('yyyy-MM-dd').format(t) ==
        DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('MMM d').format(t);
  }

  /// Consistent color per avatar initial
  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF4CAF50),
      Color(0xFFF57C00),
      Color(0xFFD32F2F),
      Color(0xFF0288D1),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
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
        controller: _searchController,
        cursorColor: kGreen,
        style: const TextStyle(
          fontSize: 13,
          color: kTextPrimary,
          fontFamily: 'Poppins',
        ),
        decoration: InputDecoration(
          hintText: 'Search conversations…',
          hintStyle: TextStyle(
            color: kTextSecondary.withOpacity(0.7),
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
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
            decoration: BoxDecoration(
              color: kGreenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: kGreen, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No conversations yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Text('Tap + to start a new chat',
              style: TextStyle(
                  fontSize: 13,
                  color: kTextSecondary,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildChatTile(int index) {
    final user = _filteredUsers[index];
    final uid  = user['uid'] as String;
    final name = (user['firstName'] as String? ?? '').trim();
    final initials = name.isNotEmpty
        ? (name.contains(' ')
        ? '${name.split(' ')[0][0]}${name.split(' ')[1][0]}'.toUpperCase()
        : name[0].toUpperCase())
        : '?';

    final docId = widget.currentUser.uid.compareTo(uid) < 0
        ? '${widget.currentUser.uid}_$uid'
        : '${uid}_${widget.currentUser.uid}';

    return Column(
      children: [
        InkWell(
          onTap: () => _navigateToChat(user),
          splashColor: kGreenLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: _avatarColor(name.isNotEmpty ? name : '?'),
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Poppins')),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _getLastMessage(docId),
                    builder: (context, snap) {
                      final msg = snap.data?['message'] as String? ?? '';
                      final ts  = snap.data?['timestamp'] as Timestamp?;
                      final time = _formatTime(ts);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name.isNotEmpty ? name : 'Unknown',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: kTextPrimary,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                              if (time.isNotEmpty)
                                Text(time,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: kTextSecondary,
                                        fontFamily: 'Poppins')),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            msg.isNotEmpty ? msg : 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
        // Divider indented past avatar
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
          'Chats',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          // New-chat icon button
          GestureDetector(
            onTap: () async {
              final selected = await Navigator.of(context).push<Map<String, dynamic>>(
                MaterialPageRoute(
                  builder: (_) => UserListPage(currentUser: widget.currentUser),
                ),
              );
              if (selected != null &&
                  !_selectedUsers.any((u) => u['uid'] == selected['uid'])) {
                setState(() {
                  _selectedUsers.add(selected);
                  _filteredUsers = _selectedUsers;
                });
                await _database.doc(widget.currentUser.uid).update({
                  'selectedUsers': FieldValue.arrayUnion([selected]),
                });
              }
            },
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                  color: kGreenLight, shape: BoxShape.circle),
              child: const Icon(Icons.edit_outlined, color: kGreen, size: 18),
            ),
          ),

        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          // Section label
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RECENT',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 1.2,
                    fontFamily: 'Poppins'),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(kGreen)))
                : _filteredUsers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (_, i) => _buildChatTile(i),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationPage(
          currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}