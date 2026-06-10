import 'package:chatapp/Pages/helpers/MainNavigation.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_services.dart';
import '../Authentication/FirstPage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Profile extends StatefulWidget {
  final CustomClass currentUser;

  const Profile({super.key, required this.currentUser});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 3;

  // ─── Theme Colors ─────────────────────────────────────────────────────────
  static const Color kGreen       = Color(0xFF4CAF50);
  static const Color kGreenDark   = Color(0xFF2E7D32);
  static const Color kGreenLight  = Color(0xFFF0FAF4);
  static const Color kGreenBorder = Color(0xFFD4EDDA);
  static const Color kTextPrimary = Color(0xFF111111);
  static const Color kTextMuted   = Color(0xFFAAAAAA);
  static const Color kDivider     = Color(0xFFF0F0F0);
  static const Color kCardBg      = Color(0xFFF8FDF9);

  // ─── Data State ───────────────────────────────────────────────────────────
  String firstName = "";
  String email     = "";
  String phone     = "";
  bool   _isLoading = true; // ← tracks whether data has loaded yet

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

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ─── FIX: fetch data correctly and guard against unmounted widget ──────────
  Future<void> _fetchUserData() async {
    // Show loader while fetching
    if (mounted) setState(() => _isLoading = true);

    try {
      // First try from widget.currentUser if already populated
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseUser.uid)  // always use FirebaseAuth uid — reliable
          .get();

      if (!mounted) return; // widget may have been disposed while awaiting

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        String fetchedName  = (data['firstName'] as String? ?? '').trim();
        String fetchedEmail = (data['email']     as String? ?? '').trim();
        String fetchedPhone = (data['phone']      as String? ?? '').trim();

        // Capitalise first letter
        if (fetchedName.isNotEmpty) {
          fetchedName = fetchedName[0].toUpperCase() + fetchedName.substring(1);
        }

        setState(() {
          firstName  = fetchedName;
          email      = fetchedEmail;
          phone      = fetchedPhone;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Profile fetchUserData error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String get _initials {
    if (firstName.isEmpty) return '?';
    final parts = firstName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return firstName[0].toUpperCase();
  }

  // ─── Sub-widgets ──────────────────────────────────────────────────────────
  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kGreenDark,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: kTextMuted,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 11,
                            color: kTextMuted,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins')),
                    const SizedBox(height: 3),
                    // ── FIX: show shimmer placeholder while loading ──────────
                    _isLoading
                        ? Container(
                      height: 14,
                      width: 140,
                      decoration: BoxDecoration(
                        color: kCardBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    )
                        : Text(
                      value.isNotEmpty ? value : '—',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFCCCCCC), size: 22),
            ],
          ),
        ),
        Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 74,
            endIndent: 0,
            color: kDivider),
      ],
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.sizeOf(context).width;
    final isWide = width > 600 || kIsWeb;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kTextPrimary),
        ),
              ),
      body: Center(
        child: ConstrainedBox(
          constraints:
          BoxConstraints(maxWidth: isWide ? 480 : double.infinity),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              // ── Avatar + Name ────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [kGreen, kGreenDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          // ── FIX: show spinner inside avatar until loaded ──
                          child: _isLoading
                              ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            _initials,
                            style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: -4,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: pick photo
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: kGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2.5)),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── FIX: show name clearly in bold, not all-caps grey ──
                    _isLoading
                        ? Container(
                      height: 18,
                      width: 120,
                      decoration: BoxDecoration(
                        color: kCardBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                        : Text(
                      firstName.isNotEmpty ? firstName : 'Your Name',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary,
                          fontFamily: 'Poppins'),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                          color: kGreenLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kGreenBorder)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                                color: kGreen, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('Online',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: kGreenDark,
                                  fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Stats ────────────────────────────────────────────────
              // Container(
              //   color: Colors.white,
              //   padding: const EdgeInsets.symmetric(
              //       horizontal: 16, vertical: 16),
              //   child: Row(
              //     children: [
              //       _buildStatCard('142', 'Chats'),
              //       _buildStatCard('8', 'Groups'),
              //       _buildStatCard('24', 'Status'),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 10),

              // ── Account Info ─────────────────────────────────────────
              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text('ACCOUNT INFO',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: kTextMuted,
                              letterSpacing: 1.2,
                              fontFamily: 'Poppins')),
                    ),
                    _buildInfoRow(
                      icon: Icons.person_outline_rounded,
                      iconColor: kGreen,
                      iconBg: kGreenLight,
                      label: 'Full Name',
                      value: firstName,
                    ),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      iconColor: const Color(0xFF1976D2),
                      iconBg: const Color(0xFFE8F4FD),
                      label: 'Email',
                      value: email,
                    ),
                    if (phone.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        iconColor: const Color(0xFFF57C00),
                        iconBg: const Color(0xFFFFF4E8),
                        label: 'Phone',
                        value: phone,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Log Out ──────────────────────────────────────────────
              Container(
                color: Colors.white,
                child: ListTile(
                  onTap: () {
                    logOutUser().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const Firstpage()),
                            (_) => false,
                      );
                    });
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.logout_rounded,
                        color: Color(0xFFE53935), size: 20),
                  ),
                  title: const Text('Log Out',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE53935),
                          fontFamily: 'Poppins')),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFCCCCCC)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 4),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationPage(
          currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}