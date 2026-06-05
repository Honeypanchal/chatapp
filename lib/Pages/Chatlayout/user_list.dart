import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/Chatlayout/chat_layout.dart';

class UserListPage extends StatefulWidget {
  final CustomClass currentUser;

  const UserListPage({super.key, required this.currentUser});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  // ─── Theme ────────────────────────────────────────────────────────────────
  static const Color kGreen       = Color(0xFF4CAF50);
  static const Color kGreenLight  = Color(0xFFF0FAF4);
  static const Color kGreenDark   = Color(0xFF2E7D32);
  static const Color kGreenBorder = Color(0xFFD4EDDA);
  static const Color kTextPrimary   = Color(0xFF111111);
  static const Color kTextSecondary = Color(0xFF888888);
  static const Color kDivider     = Color(0xFFF0F0F0);

  // ─── State ────────────────────────────────────────────────────────────────
  final _database = FirebaseFirestore.instance.collection('Users');
  final dynamic _chatsDB = FirebaseFirestore.instance.collection('chats');

  List<Map<String, dynamic>> _allUsers      = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final snap = await _database.get();
      final users = snap.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .where((u) => u['uid'] != widget.currentUser.uid)
          .toList();
      setState(() {
        _allUsers      = users;
        _filteredUsers = users;
        _isLoading     = false;
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((u) =>
          (u['firstName'] as String? ?? '').toLowerCase().contains(q))
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Deterministic avatar color from name
  Color _avatarColor(String name) {
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

  /// Up to 2-letter initials
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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
            fontSize: 13, color: kTextPrimary, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: 'Search people…',
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
            child: const Icon(Icons.person_search_outlined,
                color: kGreen, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No users found',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term',
            style: TextStyle(
                fontSize: 13,
                color: kTextSecondary,
                fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final name = (user['firstName'] as String? ?? '').trim();

    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context, user);
            _navigateToChat(user);
          },
          splashColor: kGreenLight,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _avatarColor(name),
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Poppins'),
                  ),
                ),
                const SizedBox(width: 14),

                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Unknown',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                            fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to start a chat',
                        style: TextStyle(
                            fontSize: 12,
                            color: kTextSecondary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),

                // Chat icon chip
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                      color: kGreenLight, shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: kGreen, size: 15),
                ),
              ],
            ),
          ),
        ),
        // Indented divider
        Padding(
          padding: const EdgeInsets.only(left: 76),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: kGreenLight, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kGreen, size: 16),
          ),
        ),
        title: const Text(
          'New Chat',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              fontFamily: 'Poppins'),
        ),
        actions: [
          // Live user count badge
          if (!_isLoading && _filteredUsers.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: kGreenLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kGreenBorder)),
                child: Text(
                  '${_filteredUsers.length} users',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kGreenDark,
                      fontFamily: 'Poppins'),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kGreen)))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'ALL USERS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: kTextSecondary.withOpacity(0.7),
                  letterSpacing: 1.2,
                  fontFamily: 'Poppins'),
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (_, i) =>
                  _buildUserTile(_filteredUsers[i]),
            ),
          ),
        ],
      ),
    );
  }
}