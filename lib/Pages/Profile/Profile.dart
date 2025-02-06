import 'package:chatapp/Pages/helpers/MainNavigation.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {

  final CustomClass currentUser;
  const Profile({super.key,required this.currentUser});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  int _selectedIndex=3;

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
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection("Users").doc(user.uid).get();

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
        backgroundColor: Colors.black,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Profile",
            style: TextStyle(fontFamily: 'poppins', fontSize: width * 0.04,color: Colors.white,fontWeight: FontWeight.bold),
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
                radius: 50,
                backgroundColor: Colors.green.shade400,
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : "",
                  style: TextStyle(
                    fontSize: width * 0.08,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: height*0.04,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: width*0.02),
              height:height*0.1,
              width: width,
              decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8,right: 8,top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.perm_identity,color: Colors.black26,size: width*0.09,),
                    SizedBox(width: width*0.03,),
                    Column(
                      children: [Text("Name",style: TextStyle(color: Colors.black,fontSize: width*0.035,fontFamily: 'poppins',fontWeight: FontWeight.w700),
                      ),
                        SizedBox(height: height*0.003,),
                        Text(firstName.isNotEmpty ? firstName :"",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontFamily: 'Raleways',fontSize: width*0.035),
                        ),

                      ],
                    ),
                  ],
                ),
              ),

            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: width*0.02),
              height:height*0.1,
              width: width,
              decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8,right: 8,top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Icon(Icons.email_outlined,color: Colors.black26,size: width*0.09,),
                    SizedBox(width: width*0.05,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text("Email",
                        style: TextStyle(color: Colors.black,fontSize: width*0.035,fontFamily: 'poppins',fontWeight: FontWeight.w700),
                      ),
                        SizedBox(height: height*0.005,),
                        Text(email.isNotEmpty ? email
                            :"",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontFamily: 'Raleways',fontSize: width*0.035),
                        ),

                      ],
                    ),
                  ],
                ),
              ),

            ),



          ],
        ),
      ),
      bottomNavigationBar: MainNavigationPage(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
