import 'package:chatapp/Pages/helpers/MainNavigation.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_services.dart';
import '../Authentication/FirstPage.dart';

class Profile extends StatefulWidget {
  final CustomClass currentUser;

  const Profile({super.key, required this.currentUser});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/chatPage',
            arguments: {'currentUser': widget.currentUser});
        break;
      case 1:
        Navigator.pushNamed(
          context,
          '/groupDisplay',
          arguments: {'currentUser': widget.currentUser},
        );
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

  String firstName = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          firstName = userDoc["firstName"] ?? "";
          email = userDoc["email"] ?? "";

          // Capitalize first letter of firstName
          if (firstName.isNotEmpty) {
            firstName = firstName[0].toUpperCase() + firstName.substring(1);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Profile",
            style: TextStyle(
                fontFamily: 'poppins',
            
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: width> 600 ? width *0.07 : width *0.15,
                backgroundColor: Colors.grey.shade300,
             child: Icon(Icons.person,color: Colors.white,
               size: width>600 ? width *0.1: width*0.16,),
              ),
            ),
            SizedBox(
              height: height * 0.04,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.02),
              height: height * 0.1,
              width: width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.perm_identity,
                      color: Colors.grey,
                      size: width > 600 ? width*0.04 : width *0.08,
                    ),
                    SizedBox(width:width>600 ? width*0.018: width*0.03),

                    Column(
                      children: [
                        Text(
                          "Name",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: width> 600 ? width*0.015 : width*0.035,
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w700),
                        ),

                        Text(
                          firstName.isNotEmpty ? firstName : "",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Raleways',
                            fontSize: width> 600 ? width*0.015 : width*0.035,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: width>600 ? height*0.05 : height*0),
            Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.02),
              height: height * 0.12,
              width: width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.grey,
                      size: width > 600 ? width*0.035 : width *0.075,
                    ),
                    SizedBox(width:width>600 ? width*0.02: width*0.03)
                    ,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: width> 600 ? width*0.015 : width*0.035,
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: height * 0.005,
                        ),
                        Text(
                          email.isNotEmpty ? email : "",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Raleways',
                            fontSize: width> 600 ? width*0.015 : width*0.035,),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: width>600 ? height*0.015 : 0.00),
            Container(
              margin: EdgeInsets.symmetric(horizontal: width>600? width*0.02 : width*0.002),
              child: ListTile(

                onTap: (){
                  logOutUser().then((_){
                    Navigator.pushAndRemoveUntil
                      (
                      context,
                      MaterialPageRoute(builder: (context) => Firstpage()), // Navigate to login screen
                          (Route<dynamic> route) => false, // Remove all previous routes from stack
                       );
                  });

                },
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: width>600? width*0.02 : width*0.067,

                ),

                title: Text(
                  "Log out",
                  style: TextStyle(fontFamily: 'Raleway', color: Colors.red,
                  fontSize: width>600? width*0.02: width*0.045),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: MainNavigationPage(
          currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
