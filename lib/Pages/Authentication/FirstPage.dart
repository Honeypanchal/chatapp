import 'package:chatapp/Pages/Authentication/SigninPage.dart';
import 'package:chatapp/Pages/Authentication/Signup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  // ─── Theme ────────────────────────────────────────────────────────────────
  static const Color kGreen      = Color(0xFF4CAF50);
  static const Color kGreenDark  = Color(0xFF2E7D32);
  static const Color kGreenLight = Color(0xFFF0FAF4);
  static const Color kTextPrimary   = Color(0xFF111111);
  static const Color kTextSecondary = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final isWide = kIsWeb || width > 600;
    final double contentWidth = isWide ? 420.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 0 : 24,
                vertical:   24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.04),

                  // ── Logo ─────────────────────────────────────────────
                  Center(child: Image.asset("assets/images/app_logo.png",height: 120,)),

                  const SizedBox(height: 16),

                  // ── App name ──────────────────────────────────────────
                  const Text(
                    'ChatApp',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: kTextPrimary,
                      fontFamily: 'Poppins',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Simple, fast & secure messaging\nfor everyone around you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: kTextSecondary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: height * 0.04),

                  // ── Chat bubbles illustration ─────────────────────────
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: kGreenLight,
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       _buildBubble('Hey! How are you? 👋', true),
                  //       const SizedBox(height: 10),
                  //       _buildBubble("I'm doing great, thanks!", false),
                  //       const SizedBox(height: 10),
                  //       _buildBubble('Let\'s catch up soon 🎉', true),
                  //     ],
                  //   ),
                  // ),



                  SizedBox(height: height * 0.04),

                  // ── Sign In button ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPrimaryButton(
                      label: 'Sign In',
                      icon: Icons.login_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SigninPage()),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── OR divider ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.grey.shade200,
                              endIndent: 16,indent: 16,
                              thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade400,
                                fontFamily: 'Poppins')),
                      ),
                      Expanded(
                          child: Divider(color: Colors.grey.shade200,
                              thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Create Account button ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildOutlineButton(
                      label: 'Create Account',
                      icon: Icons.person_add_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SignupPage()),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.04),

                  // ── Footer ────────────────────────────────────────────
                  Text(
                    'By continuing you agree to our Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontFamily: 'Poppins'),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Bubble widget ────────────────────────────────────────────────────────
  Widget _buildBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 220),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isMe ? 4 : 16),
            bottomRight: Radius.circular(isMe ? 16 : 4),
          ),
          boxShadow: [
            if (!isMe)
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isMe ? Colors.white : const Color(0xFF333333),
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  // ─── Button helpers ───────────────────────────────────────────────────────
  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}