// import 'package:chatapp/Authentication/CustomClass.dart';
// import 'package:chatapp/Authentication/auth_services.dart';
// import 'package:chatapp/Pages/FirstPage.dart';
// import 'package:flutter/material.dart';
// import 'package:chatapp/Pages/Signup.dart';
// import 'MainNavigation.dart';
//
// class SigninPage extends StatefulWidget {
//   @override
//   State<SigninPage> createState() => _SigninPageState();
// }
//
// class _SigninPageState extends State<SigninPage> {
//   bool check = true;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool showPass = true;
//
//   bool _isValidEmail(String email) {
//     return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
//         .hasMatch(email);
//   }
//
//
//   void _signin() async {
//     if (_formKey.currentState!.validate()) {
//       final email = _emailController.text.trim();
//       final password = _passwordController.text.trim();
//       try {
//         CustomClass? user = await signInUser(email, password);
//         if (user != null) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//                 builder: (context) => MainNavigationPage(currentUser: user)),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('User does not exist!!'),
//               backgroundColor: Colors.red.shade200,
//             ),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString()),
//             backgroundColor: Colors.red.shade200,
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//
//     return Scaffold(
//
//       body:
//       SafeArea(
//         child: SingleChildScrollView(
//           child:
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: screenWidth * 0.1,
//               vertical: screenHeight * 0.03,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Let's sign you in.",
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: screenWidth * 0.059,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//                 SizedBox(
//                   height: screenHeight * 0.015,
//                 ),
//                 Text(
//                   "Welcome back.",
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: screenWidth * 0.029,
//                       color: Colors.white),
//                 ),
//                 Text(
//                   "You've been missed!",
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: screenWidth * 0.029,
//                       color: Colors.white),
//                 ),
//                 SizedBox(
//                   height: screenHeight * 0.025,
//                 ),
//                 Container(
//                   margin: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
//                   height: screenHeight,
//                   width: screenWidth,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(top: screenHeight * 0.015),
//                         child: Text(
//                           'Sign in',
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.059,
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.03),
//                       Padding(
//                         padding: EdgeInsets.only(top: screenHeight * 0.015),
//                         child: Form(
//                           key: _formKey,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Your Email",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: screenWidth * 0.035,
//                                     fontFamily: 'Raleway'),
//                               ),
//                               SizedBox(
//                                 height: screenHeight * 0.007,
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFF2C313F),
//                                   borderRadius: BorderRadius.circular(
//                                       screenWidth * 0.045),
//                                 ),
//                                 child:
//                                 TextFormField(
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontFamily: 'Raleway'),
//                                   controller: _emailController,
//                                   decoration: InputDecoration(
//                                     labelStyle: TextStyle(
//                                         fontFamily: 'Raleway',
//                                         color: Colors.white),
//                                     labelText: 'Email',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   keyboardType: TextInputType.emailAddress,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Email cannot be empty';
//                                     }
//                                     if (!_isValidEmail(value)) {
//                                       return 'Enter a valid email';
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               Text(
//                                 "Password",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: screenWidth * 0.035,
//                                     fontFamily: 'Raleway'),
//                               ),
//                               SizedBox(
//                                 height: screenHeight * 0.007,
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFF2C313F),
//                                   borderRadius: BorderRadius.circular(
//                                       screenWidth * 0.045),
//                                 ),
//                                 child:
//                                 TextFormField(
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontFamily: 'Raleway'),
//                                   controller: _passwordController,
//                                   decoration: InputDecoration(
//                                     labelStyle: TextStyle(
//                                         fontFamily: 'Raleway',
//                                         color: Colors.white),
//                                     labelText: 'Password',
//                                     border: OutlineInputBorder(),
//                                     suffixIcon: IconButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             showPass = !showPass;
//                                           });
//                                         },
//                                         icon: showPass
//                                             ? Icon(Icons.visibility_outlined,
//                                                 color: Colors.white)
//                                             : Icon(
//                                                 Icons.visibility_off_outlined,
//                                                 color: Colors.white,
//                                               )),
//                                   ),
//                                   obscureText: !showPass,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Password cannot be empty';
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: screenHeight * 0.012,
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Checkbox(
//                                       value: check,
//                                       onChanged: (val) {
//                                         setState(() {
//                                           check = !check;
//                                         });
//                                       }),
//                                   Text(
//                                     "Remember Me ",
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontFamily: 'Raleway',
//                                         fontSize: screenWidth * 0.032),
//                                   ),
//                                   SizedBox(
//                                     width: screenWidth * 0.1,
//                                   ),
//                                   Align(
//                                     alignment: Alignment.topRight,
//                                     child: Opacity(
//                                       opacity: 0.6,
//                                       child: Text(
//                                         "Forgot password?",
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontFamily: 'Raleway',
//                                             fontSize: screenWidth * 0.032),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: screenHeight * 0.03),
//                               GestureDetector(
//                                 onTap: _signin,
//                                 child: Container(
//                                   height: screenHeight * 0.06,
//                                   decoration: BoxDecoration(
//                                       color: Color(0xFF995BF8),
//                                       borderRadius: BorderRadius.circular(
//                                           screenWidth * 0.05)),
//                                   child: Center(
//                                     child: Text(
//                                       "Sign in",
//                                       style: TextStyle(
//                                         fontFamily: 'Poppins',
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: screenWidth * 0.05,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               TextButton(
//                                   onPressed: () {
//                                     Navigator.of(context).push(
//                                       MaterialPageRoute(
//                                           builder: (context) => SignupPage()),
//                                     );
//                                   },
//                                   child: Center(
//                                     child: Text.rich(TextSpan(
//                                         text: "I'm a new user .",
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontFamily: 'Raleway',
//                                           fontSize: screenWidth * 0.032,
//                                         ),
//                                         children: <InlineSpan>[
//                                           TextSpan(
//                                               text: 'Sign Up ',
//                                               style: TextStyle(
//                                                 fontFamily: 'Raleway',
//                                                 color: Color(0xFF995BF8),
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: screenWidth * 0.032,
//                                               ))
//                                         ])),
//                                   )),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/services/auth_services.dart';
import 'package:chatapp/Pages/FirstPage.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Pages/Signup.dart';
import 'MainNavigation.dart';

class SigninPage extends StatefulWidget {
  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  bool check = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool showPass = true;

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
        .hasMatch(email);
  }

  void _signin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      try {
        CustomClass? user = await signInUser(email, password);
        print("$user");
        print("$email and $password");
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => MainNavigationPage(currentUser: user)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User does not exist!!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style:
                  TextStyle(fontWeight: FontWeight.w300, fontFamily: 'poppins'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/main4.png',
              fit: BoxFit.cover,
            ),
            Text("Let's Sign In",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: width * 0.09,)),
            /*Text(
              'LOGIN',
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),*/
            SizedBox(
              height: height * 0.013,
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 10.0, left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email Address',
                        style: TextStyle(
                            fontSize: width * 0.036,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.008,
                    ),
                    /*Text(
                      'EMAIL',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: width * 0.03,
                        color: Colors.blueAccent,
                        fontFamily: 'poppins'
                      ),
                    ),*/
                    TextFormField(
                      style: TextStyle(
                          color: Colors.black, fontFamily: 'Raleway'),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        // label: Text('Email'),
                        border: OutlineInputBorder(),
                      ),
                      /*decoration: InputDecoration(
                        labelStyle: TextStyle(
                            fontFamily: 'Raleway',
                            color: Colors.black),
                      ),*/
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (!_isValidEmail(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.035),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                            fontSize: width * 0.036,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'poppins'),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.008,
                    ),
                    /*Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: width * 0.03,
                        color: Colors.blueAccent,
                        fontFamily: 'poppins',
                      ),
                    ),*/
                    TextFormField(
                      style: TextStyle(
                          color: Colors.black, fontFamily: 'Raleway'),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        fillColor: Colors.white38,
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                        border: OutlineInputBorder(),
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.grey),
                        // helperText: "Password must contain special character",
                        helperStyle: TextStyle(color: Colors.green),
                        labelStyle: TextStyle(
                            fontFamily: 'Raleway', color: Colors.black),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                            icon: showPass
                                ? Icon(Icons.visibility_outlined,
                                    color: Colors.grey)
                                : Icon(
                                    Icons.visibility_off_outlined,
                                    color: Colors.black,
                                  )),
                      ),
                      obscureText: !showPass,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.035,
            ),
            SizedBox(
              height: height * 0.070,
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: () {
                  _signin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Sign In',style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.055,
                  color: Colors.white,
                ),),
              ),
            ),
            SizedBox(height: height * 0.013),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      // fontWeight: FontWeight.w600,
                      fontSize: width * 0.035,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.037,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.010,
            ),
            Text(
              'FORGOT PASSWORD?',
              style: TextStyle(
                fontSize: width * 0.032,
                fontWeight: FontWeight.w500,
              ),
            ),
            // SizedBox(height: height * 0.013),
            /*Text(
              'OR',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: width * 0.030,
                color: Colors.grey,
              ),
            ),*/

          ],
        ),
      ),
    );
  }
}
