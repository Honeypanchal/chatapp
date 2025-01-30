import 'package:chatapp/services/status_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class Statuspage extends StatefulWidget {
  @override
  State<Statuspage> createState() => _StatuspageState();
}

class _StatuspageState extends State<Statuspage> {
  final StatusService _statusService = StatusService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadStatus() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _statusService.uploadStatus([image.path]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Status',
          style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.w600,
              fontSize: width * 0.06),
        ),

      ),
      body: StreamBuilder(stream: _statusService.getStatuses(), builder: (context,snapshot)
      {
        if(!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
        List<Status> statuses=snapshot.data!;
        return ListView.builder(itemCount: statuses.length,itemBuilder: (context,index)
        {
          Status status=statuses[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(status.photoUrl),
            ),
            title: Text(status.username),
            subtitle: Text('${status.timestamp.toDate()}'),
            onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>
              ViewStatusScreen(status:status)),
              );
            }

          );
        });
      },

      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        _uploadStatus();
      },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: Icon(Icons.add_a_photo,color: Colors.white,size: width*0.04,),
        
        
      ),
    );
  }
}
class ViewStatusScreen extends StatelessWidget {
  final Status status;

 final StatusService _statusService=StatusService();

 ViewStatusScreen({required this.status});

  @override
  Widget build(BuildContext context) {
    _statusService.markStatusAsViewed(status.uid);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Image.network(status.statusImageUrls[0]),
    );
  }
}

//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(title: Text("Status")),
//     body: StreamBuilder<List<Status>>(
//       stream: _statusService.getStatuses(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
//
//         List<Status> statuses = snapshot.data!;
//         return ListView.builder(
//           itemCount: statuses.length,
//           itemBuilder: (context, index) {
//             Status status = statuses[index];
//             return ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: NetworkImage(status.photoUrl),
//               ),
//               title: Text(status.username),
//               subtitle: Text("Posted at: ${status.timestamp.toDate()}"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ViewStatusScreen(status: status)),
//                 );
//               },
//             );
//           },
//         );
//       },
//     ),
//     floatingActionButton: FloatingActionButton(
//       child: Icon(Icons.add),
//       onPressed: _uploadStatus,
//     ),
//   );
// }
// }
//
// // Status View Screen
// class ViewStatusScreen extends StatelessWidget {
//   final Status status;
//   final StatusService _statusService = StatusService();
//
//   ViewStatusScreen({required this.status});
//
//   @override
//   Widget build(BuildContext context) {
//     _statusService.markStatusAsViewed(status.uid);
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Image.network(status.statusImageUrls[0]),
//       ),
//     );
//   }
// }