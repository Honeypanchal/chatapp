import 'package:chatapp/Authentication/CustomClass.dart';

import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  final CustomClass user;

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text('Name: ${user.name ?? "N/A"}'),
              SizedBox(height: 10),
              Text('Email: ${user.email ?? "N/A"}'),
              SizedBox(height: 10),
              Text('Password: ${user.password ?? "N/A"}'),
              SizedBox(height: 10),
              user.photoURL != null
                  ? Image.network(user.photoURL!)
                  : Icon(Icons.account_circle, size: 100),
              SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Connection()));
              }, child: Text("Home"))
            ],
          ),
        ),
      ),
    );
  }
}
