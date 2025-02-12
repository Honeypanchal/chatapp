

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupChatPage.dart';

class MessageInfoPage extends StatefulWidget {
  final String messageId;
  final String groupId;
  final VoidCallback markMessagesAsRead;
  MessageInfoPage({required this.messageId, required this.groupId,  required this.markMessagesAsRead});

  @override
  _MessageInfoPageState createState() => _MessageInfoPageState();
}

class _MessageInfoPageState extends State<MessageInfoPage> {
  Map<String, String> participantNames = {}; // Stores userId -> Name mapping

  @override
  void initState() {
    super.initState();
    fetchParticipants();
    widget.markMessagesAsRead();
  }

  // 🛠️ Fetch all participant names once and store them
  Future<void> fetchParticipants() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();
      var groupData = groupSnapshot.data() as Map<String, dynamic>? ?? {};

      if (groupData.containsKey('participants')) {
        List<String> participants = List<String>.from(groupData['participants']);
        await fetchUserNames(participants);
      }
    } catch (e) {
      print("Error fetching participants: $e");
    }
  }


  Future<void> fetchUserNames(List<String> userIds) async {
    if (userIds.isEmpty) return;
    Map<String, String> tempNames = {};

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    for (var doc in userSnapshot.docs) {
      var userData = doc.data() as Map<String, dynamic>? ?? {};
      tempNames[doc.id] = userData['firstName'] ?? "Unknown User"; // Fetch firstName
    }

    setState(() {
      participantNames.addAll(tempNames);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Message Info")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .doc(widget.messageId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var messageData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          String messageText = messageData["message"] ?? "Unknown Message";
          Timestamp? timestamp = messageData["timestamp"];
          List<String> readBy = List<String>.from(messageData["readBy"] ?? []);
          List<String> deliveredTo = List<String>.from(messageData["deliveredTo"] ?? []);

          return Column(
            children: [
              _buildMessageCard(messageText, timestamp), // 📨 Message Display

              Divider(),

              _buildSectionHeader("Read By"),
              _buildUserList(readBy, seen: true), // ✅ Show Read Users

              Divider(),

              _buildSectionHeader("Delivered To"),
              _buildUserList(deliveredTo.where((uid) => !readBy.contains(uid)).toList(), seen: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageCard(String messageText, Timestamp? timestamp) {
    return Card(
      margin: EdgeInsets.all(12),
      color: Color.fromARGB(255, 213, 252, 208), // ✅ Background Color
      child: ListTile(
        title: Text("Message", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(messageText, style: TextStyle(fontSize: 16)),
        trailing: Text(
          timestamp != null ? _formatTimestamp(timestamp) : "Time Unknown",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('hh:mm a, MMM d').format(date);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }


  Widget _buildUserList(List<String> userIds, {required bool seen}) {
    return Expanded(
      child: ListView.builder(
        itemCount: userIds.length,
        itemBuilder: (context, index) {
          String uid = userIds[index];
          String name = participantNames[uid] ?? "Fetching...";

          return ListTile(
            leading: _buildUserAvatar(name),
            title: Text(name),
           // subtitle: Text(seen ? "✔✔ Seen" : "✔ Delivered"),
          );
        },
      ),
    );
  }


  Widget _buildUserAvatar(String name) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green, width: 2), // Green border
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white, // White background
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
