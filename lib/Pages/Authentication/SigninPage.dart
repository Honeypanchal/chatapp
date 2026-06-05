import 'package:chatapp/Pages/ChatLayout/ChatPage.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Pages/Authentication/Signup.dart';
import 'package:flutter/foundation.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  // ─── Theme ────────────────────────────────────────────────────────────────
  static const Color kGreen      = Color(0xFF4CAF50);
  static const Color kGreenLight = Color(0xFFF0FAF4);
  static const Color kGreenDark  = Color(0xFF2E7D32);
  static const Color kTextPrimary   = Color(0xFF111111);
  static const Color kTextSecondary = Color(0xFF888888);

  // ─── State (unchanged logic) ──────────────────────────────────────────────
  final GlobalKey<FormState> _formKey         = GlobalKey<FormState>();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPass    = false;
  bool _isLoading   = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
          .hasMatch(email);

  // ── Sign-in logic — completely unchanged ──────────────────────────────────
  void _signin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      CustomClass? user = await signInUser(email, password);
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ChatPage(currentUser: user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User does not exist!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.w300, fontFamily: 'Poppins')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final isWide = kIsWeb || width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 420 : double.infinity),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 0 : 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Back button ─────────────────────────────────────


                  SizedBox(height: height * 0.035),

                  // ── Logo + heading ───────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Image.asset("assets/images/app_logo.png",height: 120,),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: kTextPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to continue chatting',
                          style: TextStyle(
                            fontSize: 13,
                            color: kTextSecondary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.04),

                  // ── Form ─────────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email
                        _buildLabel('EMAIL ADDRESS'),
                        const SizedBox(height: 6),
                        _buildEmailField(),

                        SizedBox(height: height * 0.022),

                        // Password
                        _buildLabel('PASSWORD'),
                        const SizedBox(height: 6),
                        _buildPasswordField(),

                        const SizedBox(height: 10),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: forgot password
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: kGreen,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.03),

                        // Sign In button
                        _buildSignInButton(),

                        SizedBox(height: height * 0.02),

                        // Sign up link
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => SignupPage()),
                            ),
                            child: RichText(
                              text: const TextSpan(
                                text: "Don't have an account?  ",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: kTextSecondary,
                                    fontFamily: 'Poppins'),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                        color: kTextPrimary,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sub-widgets ──────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: kTextSecondary.withOpacity(0.8),
        letterSpacing: 0.8,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      cursorColor: kGreen,
      style: const TextStyle(
          fontSize: 14, color: kTextPrimary, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        hintText: 'you@example.com',
        hintStyle: const TextStyle(
            color: Color(0xFFBBBBBB), fontFamily: 'Poppins', fontSize: 13),
        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFBBBBBB), size: 20),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kGreen, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email cannot be empty';
        if (!_isValidEmail(value)) return 'Enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_showPass,
      cursorColor: kGreen,
      style: const TextStyle(
          fontSize: 14, color: kTextPrimary, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        hintText: 'Enter your password',
        hintStyle: const TextStyle(
            color: Color(0xFFBBBBBB), fontFamily: 'Poppins', fontSize: 13),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: Color(0xFFBBBBBB), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _showPass
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFFBBBBBB),
            size: 20,
          ),
          onPressed: () => setState(() => _showPass = !_showPass),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kGreen, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password cannot be empty';
        return null;
      },
    );
  }

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _signin,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isLoading ? kGreen.withOpacity(0.7) : kGreen,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}