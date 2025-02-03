// import 'package:chatapp/models/CustomClass.dart';
//
// import 'package:flutter/material.dart';
//
//
// class ProfilePage extends StatelessWidget {
//   final CustomClass user;
//
//   ProfilePage({required this.user});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Align(
//           alignment: Alignment.topCenter,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Text('Name: ${user.name ?? "N/A"}'),
//               SizedBox(height: 10),
//               Text('Email: ${user.email ?? "N/A"}'),
//               SizedBox(height: 10),
//               Text('Password: ${user.password ?? "N/A"}'),
//               SizedBox(height: 10),
//               user.photoURL != null
//                   ? Image.network(user.photoURL!)
//                   : Icon(Icons.account_circle, size: 100),
//               SizedBox(height: 20,),
//               ElevatedButton(onPressed: (){
//                 // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Connection()));
//               }, child: Text("Home"))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontFamily: 'poppins'),
      ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white54),

          )
        ],
      )

    );
  }
}
