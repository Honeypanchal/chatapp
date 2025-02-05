import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic> messageData;
  final Timestamp? deliveredAt;
  final Timestamp? readAt;

  UserInfoPage({
    required this.messageData,
    required this.deliveredAt,
    required this.readAt,
  });

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} AM"; // HH:MM AM/PM format
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Set the background color of the entire screen
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        title: Text("Message info", style: TextStyle(color: Colors.white, fontFamily: 'Raleway')),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),  // Icon color in appBar
      ),
      body: SingleChildScrollView(  // Make the body scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${messageData['message']}",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 5),
                        Text(
                          formatTimestamp(deliveredAt),
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10), // Optional: Add spacing for better layout
            Container(
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.done_all, color: Colors.green[700]),
                    title: Text("Read", style: TextStyle(color: Colors.white)),
                    subtitle: Text(formatTimestamp(readAt), style: TextStyle(color: Colors.white70)),
                  ),
                  Divider(color: Colors.white24),
                  ListTile(
                    leading: Icon(Icons.done, color: Colors.grey),
                    title: Text("Delivered", style: TextStyle(color: Colors.white)),
                    subtitle: Text(formatTimestamp(deliveredAt), style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic> messageData;
  final Timestamp? deliveredAt;
  final Timestamp? readAt;

  UserInfoPage({
    required this.messageData,
    required this.deliveredAt,
    required this.readAt,
  });

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} AM"; // HH:MM AM/PM format
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message info", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${messageData['message']}",
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(14),
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                      ),
                      child: ListTile(
                        leading: Icon(Icons.done_all, color: Colors.blueAccent),
                        title: Text("Read", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(formatTimestamp(readAt), style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                      ),
                      child: ListTile(
                        leading: Icon(Icons.done, color: Colors.grey),
                        title: Text("Delivered", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(formatTimestamp(deliveredAt), style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic> messageData;
  final Timestamp? deliveredAt;
  final Timestamp? readAt;

  UserInfoPage({
    required this.messageData,
    required this.deliveredAt,
    required this.readAt,
  });

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} AM"; // HH:MM AM/PM format
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new_rounded),
        title: Text("Message info", style: TextStyle(color: Colors.white, fontFamily: 'Raleway')),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${messageData['message']}",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500,fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(14),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                    ),
                    child: ListTile(
                      leading: Icon(Icons.done_all, color: Colors.blueAccent),
                      title: Text("Read", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,fontFamily: 'Poppins')),
                      subtitle: Text(formatTimestamp(readAt), style: TextStyle(color: Colors.white70,fontFamily: 'Poppins')),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                    ),
                    child: ListTile(
                      leading: Icon(Icons.done, color: Colors.grey),
                      title: Text("Delivered", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontFamily: 'Poppins')),
                      subtitle: Text(formatTimestamp(deliveredAt), style: TextStyle(color: Colors.white70,fontFamily: 'Poppins')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic> messageData;
  final Timestamp? deliveredAt;
  final Timestamp? readAt;

  UserInfoPage({
    required this.messageData,
    required this.deliveredAt,
    required this.readAt,
  });

  @override
  Widget build(BuildContext context) {
    String deliveryTime = deliveredAt != null
        ? DateTime.fromMillisecondsSinceEpoch(deliveredAt!.millisecondsSinceEpoch).toString()
        : 'Not delivered yet';
    String readTime = readAt != null
        ? DateTime.fromMillisecondsSinceEpoch(readAt!.millisecondsSinceEpoch).toString()
        : 'Not read yet';

    return Scaffold(
      appBar: AppBar(title: Text("Message Info")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display message sender and content
            Text("Sender: ${messageData['sentBy']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Message: ${messageData['message']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),

            // Display delivery time
            Text("Delivery Time: $deliveryTime", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),

            // Display read time
            Text("Read Time: $readTime", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
*/
