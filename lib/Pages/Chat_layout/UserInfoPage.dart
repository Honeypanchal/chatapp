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
