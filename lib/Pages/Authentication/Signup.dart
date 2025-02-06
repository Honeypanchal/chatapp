import 'package:chatapp/Pages/ChatLayout/ChatPage.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/auth_services.dart';

import 'package:chatapp/pages/Authentication/SigninPage.dart';
import 'package:chatapp/Pages/Authentication/FirstPage.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool check = true;
  bool showPass = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
  TextEditingController();

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  int date = 1;
  List<String> months = ['Jan', 'Feb', 'March', 'April', 'May'];
  List<int> years = [2000, 2001, 2002, 2003, 2004, 2005];
  int year = 2000;
  String month = 'Jan';

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final firstName = _firstnameController.text.trim();
      final lastName = _lastnameController.text.trim();
      final confirmpassword = _confirmpasswordController.text.trim();
      print("$email");
      try {
        CustomClass? user = await signUpUser(firstName, email, password);
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => ChatPage(currentUser: user)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w400),
          ),
          backgroundColor: Colors.red,
        ));
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
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60),
          child: Column(
            children: [
              /*Container(
                  height: height * 0.5,
                  width: width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0XFF5098FA),
                        Color(0XFF526CF7),
                        Color(0XFF533BF1),
                        Color(0XFF5327EE),
                        Color(0XFF5317EB),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.065),
                          ClipOval(
                            child: SizedBox.fromSize(
                              size: Size.fromRadius(50),
                              child: Image.asset(
                                'assets/images/Icon_homepage.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),*/
              /*Image.asset(
                'assets/images/main3.png',
                height: 200,
                fit: BoxFit.cover,
              ),*/
              Text(
                'Sign Up For Free.',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'poppins',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 20.0),
                child: const Text(
                  "join us for less than 1 minutes, with no cost.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Name',
                        style: TextStyle(
                            fontSize: width * 0.033,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'poppins'),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.010,
                    ),
                    /*Text(
                      'NAME',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: width * 0.03,
                          color: Colors.blue[600],
                          fontFamily: 'poppins'),
                    ),*/
                    TextFormField(
                      style:
                      TextStyle(color: Colors.black, fontFamily: 'Raleway'),
                      controller: _firstnameController,
                      decoration: InputDecoration(
                          hintText: 'your name',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.person_2_outlined),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter Name';
                        }
                        return null;
                      },

                      /*decoration: InputDecoration(

                          // errorBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(
                          //         color: Colors.red)),

                          ),*/
                    ),
                    SizedBox(
                      height: height * 0.030,
                    ),
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
                      height: height * 0.010,
                    ),
                    TextFormField(
                      style:
                      TextStyle(color: Colors.black, fontFamily: 'Raleway'),
                      controller: _emailController,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email is required';
                        } else if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(val.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        // label: Text('Email'),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: height * 0.030),
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
                    SizedBox(height: height * 0.010),
                    TextFormField(
                      style:
                      TextStyle(color: Colors.black, fontFamily: 'Raleway'),
                      controller: _passwordController,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Enter a password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          fillColor: Colors.white38,
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          border: OutlineInputBorder(),
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey),
                          // helperText: "Password must contain special character",
                          helperStyle: TextStyle(color: Colors.green),

                          // errorBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(
                          //         color: Colors.red)),
                          suffixIcon: showPass
                              ? IconButton(
                              onPressed: () {
                                setState(() {
                                  showPass = !showPass;
                                });
                              },
                              icon: Icon(
                                  color: Colors.black,
                                  Icons.visibility_outlined))
                              : IconButton(
                              onPressed: () {
                                setState(() {
                                  showPass = !showPass;
                                });
                              },
                              icon: Icon(
                                  color: Colors.grey,
                                  Icons.visibility_off_outlined))),
                      obscureText: !showPass,
                    ),
                    SizedBox(height: height * 0.030),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Re-Type Password',
                        style: TextStyle(
                            fontSize: width * 0.033,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'poppins'),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    /*Text(
                      'RE-TYPE PASSWORD',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: width * 0.03,
                          color: Colors.blue[600],
                          fontFamily: 'poppins'),
                    ),*/
                    SizedBox(height: height * 0.010),
                    TextFormField(
                      style:
                      TextStyle(color: Colors.black, fontFamily: 'Raleway'),
                      controller: _confirmpasswordController,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Enter a password';
                        } else if (val != _passwordController.text)
                          return 'no match';
                        return null;
                      },
                      decoration: InputDecoration(
                          fillColor: Colors.white38,
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          border: OutlineInputBorder(),
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey),
                          // helperText: "Password must contain special character",
                          helperStyle: TextStyle(color: Colors.green),

                          // errorBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(
                          //         color: Colors.red)),
                          suffixIcon: showPass
                              ? IconButton(
                              onPressed: () {
                                setState(() {
                                  showPass = !showPass;
                                });
                              },
                              icon: Icon(
                                  color: Colors.black,
                                  Icons.visibility_outlined))
                              : IconButton(
                              onPressed: () {
                                setState(() {
                                  showPass = !showPass;
                                });
                              },
                              icon: Icon(
                                  color: Colors.grey,
                                  Icons.visibility_off_outlined))),
                      obscureText: !showPass,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                height: height * 0.07,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    _signup();
                  },
                  style: ElevatedButton.styleFrom(
                    // Color(0XFF185FED)
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: width * 0.045, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.015,
              ),
              SizedBox(
                height: height * 0.060,
                width: width * 0.9,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color: Colors.black,
                                width: 2
                            ))),
                    onPressed: () async {
                      CustomClass? user = await signInWithGoogle();

                      if (user != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(currentUser: user)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No user recieved")));
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          'assets/images/Google.jpg',
                          height: height * 0.054,
                          width: width * 0.054,
                        ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        Text(
                          "Sign up with google  ",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: width * 0.040),
                        ),
                      ],
                    )),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SigninPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.035,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.040,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 80,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
