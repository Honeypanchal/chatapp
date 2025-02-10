

import 'package:chatapp/Pages/ChatLayout/ChatPage.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/services/auth_services.dart';

import 'package:flutter/material.dart';
import 'package:chatapp/pages/Authentication/Signup.dart';


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
                builder: (context) => ChatPage(currentUser: user)),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',

              height: 300,
            ),
            Text("Let's Sign In",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: width * 0.08,)),
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
                            fontSize: width * 0.033,
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
                        focusColor: Color.fromRGBO(21, 171, 97, 1),
                        hintStyle: TextStyle(color: Colors.grey),
                        // label: Text('Email'),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(21, 171, 97, 1))
                        ),
                        focusedBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromRGBO(21, 171, 97, 1))
                        )
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
                            fontSize: width * 0.033,
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
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromRGBO(21, 171, 97, 1))
                        ),
                        focusColor: Color.fromRGBO(21, 171, 97, 1),
                        hintText: "Password",
                        focusedBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromRGBO(21, 171, 97, 1))
                        ),
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
                  backgroundColor:   Color.fromRGBO(21, 171, 97, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Sign In',style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.045,
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
                      fontSize: width * 0.032,
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
                fontSize: width * 0.030,
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
