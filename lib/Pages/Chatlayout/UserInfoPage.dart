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

  // Format timestamp to 24-hour format like WhatsApp
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not Read yet!';
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0), // Modern Light Gray background
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text("Message Info",
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white, // Clean White Theme
        elevation: 1, // Slight shadow for depth
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Message Bubble (Sent Message)
          Container(
            padding: EdgeInsets.all(16.0),
            color: Color(0XFFF6F1EB),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0XFFD5FCD0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${messageData['message']}",
                      style: TextStyle(
                          fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.done_all, color: Colors.blue, size: 16),
                        SizedBox(width: 5),
                        Text(
                          formatTimestamp(deliveredAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          // Read and Delivered Status
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Icon(Icons.done_all, color: Colors.blue, size: 22),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Read",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Text(formatTimestamp(readAt),
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      child: Icon(Icons.done, color: Colors.grey, size: 22),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Delivered",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Text(formatTimestamp(deliveredAt),
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



