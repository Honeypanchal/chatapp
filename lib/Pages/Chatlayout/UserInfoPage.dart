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
    if (timestamp == null) return 'Not Read yet!';
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

