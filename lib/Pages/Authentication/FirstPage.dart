import 'package:chatapp/Pages/Authentication/SigninPage.dart';
import 'package:chatapp/Pages//Authentication/Signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage>  {

  // with WidgetsBindingObserver
// -----------------------
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(this);
  //
  //   // Update status to online when the app starts
  //   _updateUserStatus(true);
  // }
  //
  // @override
  // void dispose() {
  //   // Ensure to remove the observer
  //   WidgetsBinding.instance.removeObserver(this);
  //
  //   // Update status to offline when the app is disposed
  //   _updateUserStatus(false);
  //   super.dispose();
  // }
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   // Detect app lifecycle changes
  //   if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
  //     // App is in background or closed
  //     _updateUserStatus(false);
  //   } else if (state == AppLifecycleState.resumed) {
  //     // App is in foreground
  //     _updateUserStatus(true);
  //   }
  // }
  //
  // Future<void> _updateUserStatus(bool isActive) async {
  //   User? user = _auth.currentUser;
  //   if (user != null) {
  //     await _firestore.collection('Users').doc(user.uid).update({
  //       "isActive": isActive,
  //       "lastActive": DateTime.now().millisecondsSinceEpoch,
  //     });
  //   }
  // }

  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {

          bool isWeb = constraints.maxWidth > 800;

          final height = MediaQuery.of(context).size.height;
          final width = MediaQuery.of(context).size.width;

          return SingleChildScrollView(
            child: Column(
              children: [

                SizedBox(height: height * (isWeb ? 0.05 : 0.1)),


                Container(
                  height: height * (isWeb ? 0.4 : 0.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(width * 0.35),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/main1.png',
                      height: height * (isWeb ? 0.5 : 0.6),
                      width: width * (isWeb ? 0.3 : 0.90),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.012),

                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: height * (isWeb ? 0.5 : 0.4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(width * 0.025),
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: width * (isWeb ? 0.15 : 0.062),
                        vertical: height * 0.012,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title text
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * (isWeb ? 0.12 : 0.064)),
                              child: Text(
                                "Let's Get started!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: isWeb ? width * 0.045 : width * 0.059,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.012),
                          // Subtitle text
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * (isWeb ? 0.12 : 0.06)),
                            child: Text(
                              "Chat with people around you easily.",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: width * (isWeb ? 0.022 : 0.029),
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * (isWeb ? 0.12 : 0.06)),
                            child: Text(
                              "Sign in easily using Google/Facebook",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: width * (isWeb ? 0.022 : 0.029),
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.012),
                          // Sign in button
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SigninPage()));
                            },
                            child: Container(
                              height: height * 0.06,
                              width: width,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(color: Color(0xFF9C9998)),
                                  borderRadius: BorderRadius.circular(width * 0.03)),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Sign in",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: width * (isWeb ? 0.03 : 0.04),
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.01),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: width * (isWeb ? 0.03 : 0.045),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.012),
                          // Register button
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignupPage()));
                            },
                            child: Container(
                              height: height * 0.06,
                              width: width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(width * 0.03),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Register",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: width * (isWeb ? 0.03 : 0.04),
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.01),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: width * (isWeb ? 0.03 : 0.045),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
