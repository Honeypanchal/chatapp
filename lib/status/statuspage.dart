import 'dart:async';
import 'package:chatapp/Pages/ChatLayout/ChatPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDisplayPage.dart';
import 'package:chatapp/Pages/Profile/Profile.dart';
import 'package:chatapp/Pages/helpers/MainNavigation.dart';
import 'package:chatapp/services/status_service.dart';
import 'package:chatapp/status/viewstatuspage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/CustomClass.dart';
import '../models/Status.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_services.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  // ─── Theme ────────────────────────────────────────────────────────────────
  static const Color kGreen       = Color(0xFF4CAF50);
  static const Color kGreenLight  = Color(0xFFF0FAF4);
  static const Color kGreenDark   = Color(0xFF2E7D32);
  static const Color kGreenBorder = Color(0xFFD4EDDA);
  static const Color kTextPrimary   = Color(0xFF111111);
  static const Color kTextSecondary = Color(0xFF888888);
  static const Color kDivider     = Color(0xFFF0F0F0);

  // ─── State ────────────────────────────────────────────────────────────────
  final StatusService _statusService = StatusService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late CustomClass _currentUser;
  int _selectedIndex = 2;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = await getUserDetails(_currentUserId);
    if (mounted && user != null) {
      setState(() => _currentUser = user);
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => ChatPage(currentUser: _currentUser)));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => GroupDisplayPage(currentUser: _currentUser)));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const StatusPage()));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => Profile(currentUser: _currentUser)));
        break;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF4CAF50), Color(0xFF1976D2), Color(0xFF7B1FA2),
      Color(0xFFF57C00), Color(0xFF00796B), Color(0xFFD32F2F), Color(0xFF0288D1),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  String _formatTime(Timestamp ts) {
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

  // ─── Widgets ──────────────────────────────────────────────────────────────

  /// Top "My Status" tile
  Widget _buildMyStatusTile() {
    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const EnterStatus())),
      splashColor: kGreenLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kGreen, kGreenDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                Positioned(
                  bottom: 0,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                        color: kGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.add, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Status',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 2),
                  Text('Tap to add a status update',
                      style: TextStyle(
                          fontSize: 12,
                          color: kTextSecondary,
                          fontFamily: 'Poppins')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: kTextSecondary.withOpacity(0.7),
            letterSpacing: 1.2,
            fontFamily: 'Poppins'),
      ),
    );
  }

  Widget _buildStatusTile(
      String userId,
      List<Status> statuses,
      bool isSeen) {
    final bool isMyStatus = statuses[0].userId == _currentUserId;
    final String displayName = isMyStatus ? 'My Status' : statuses[0].username;
    final String initial =
    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final String timeStr = _formatTime(statuses.last.timestamp);

    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewStatusScreen(statuses: statuses)),
            ).then((_) => setState(() {}));
          },
          splashColor: kGreenLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Ring avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSeen ? const Color(0xFFCCCCCC) : kGreen,
                        width: 2.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: CircleAvatar(
                      backgroundColor: _avatarColor(displayName),
                      child: Text(initial,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Poppins')),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kTextPrimary,
                              fontFamily: 'Poppins')),
                      const SizedBox(height: 2),
                      Text(
                        isSeen
                            ? '${statuses.length} status viewed'
                            : '${statuses.length} status available',
                        style: TextStyle(
                            fontSize: 12,
                            color: kTextSecondary,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
                Text(timeStr,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 78),
          child: Divider(height: 0.5, thickness: 0.5, color: kDivider),
        ),
      ],
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
            child: const Icon(Icons.circle_outlined, color: kGreen, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No status updates yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Text('Tap + to share your status',
              style:
              TextStyle(fontSize: 13, color: kTextSecondary, fontFamily: 'Poppins')),
        ],
      ),
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
        title: const Text('Status',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                fontFamily: 'Poppins')),
        actions: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(color: kGreenLight, shape: BoxShape.circle),
            child: const Icon(Icons.search_rounded, color: kGreen, size: 18),
          ),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(color: kGreenLight, shape: BoxShape.circle),
            child: const Icon(Icons.more_horiz_rounded, color: kGreen, size: 20),
          ),
        ],
      ),
      body: StreamBuilder<List<Status>>(
        stream: _statusService.getStatuses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(kGreen)));
          }

          // Split into seen / unseen
          final Map<String, List<Status>> unSeen = {};
          final Map<String, List<Status>> seen   = {};

          for (final s in (snapshot.data ?? [])) {
            final key = s.username;
            if (s.viewedBy.contains(_currentUserId)) {
              seen.putIfAbsent(key, () => []).add(s);
            } else {
              unSeen.putIfAbsent(key, () => []).add(s);
            }
          }

          final bool isEmpty = unSeen.isEmpty && seen.isEmpty;

          return ListView(
            children: [
              // My Status tile always visible at top
              _buildMyStatusTile(),
              const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF0F0F0)),

              if (isEmpty) ...[
                const SizedBox(height: 80),
                _buildEmptyState(),
              ] else ...[
                if (unSeen.isNotEmpty) ...[
                  _buildSectionLabel('RECENT UPDATES'),
                  ...unSeen.entries.map(
                          (e) => _buildStatusTile(e.key, e.value, false)),
                ],
                if (seen.isNotEmpty) ...[
                  _buildSectionLabel('VIEWED'),
                  ...seen.entries.map(
                          (e) => _buildStatusTile(e.key, e.value, true)),
                ],
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EnterStatus())),
        backgroundColor: kGreen,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
      bottomNavigationBar:
      MainNavigationPage(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}