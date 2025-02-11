import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class StarredAllMessagesPage extends StatefulWidget {
  const StarredAllMessagesPage({Key? key, required currentUser}) : super(key: key);

  @override
  _StarredAllMessagesPageState createState() => _StarredAllMessagesPageState();
}

class _StarredAllMessagesPageState extends State<StarredAllMessagesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userId = "";
  Map<String, String> groupNames = {};

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? "";
  }

  Future<List<String>> getUserGroups() async {
    if (userId.isEmpty) return [];

    QuerySnapshot groupsSnapshot = await _firestore
        .collection('groups')
        .where('participants', arrayContains: userId)
        .get();

    List<String> userGroups = [];
    for (var doc in groupsSnapshot.docs) {
      userGroups.add(doc.id);
      groupNames[doc.id] = doc['groupName'] ?? "Unknown Group";
    }

    return userGroups;
  }

  Future<List<Map<String, dynamic>>> getStarredMessages() async {
    List<String> userGroups = await getUserGroups();
    List<Map<String, dynamic>> allMessages = [];

    for (String groupId in userGroups) {
      QuerySnapshot messagesSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .where('favorite', isEqualTo: true)
          .orderBy('timestamp')
          .get();

      for (var doc in messagesSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['groupName'] = groupNames[groupId] ?? "Unknown Group";
        allMessages.add(data);
      }
    }

    return allMessages;
  }

  @override
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context).size.width;
    final height=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFF6F1EB),
      appBar: AppBar(
        leading: Padding(
          padding:  EdgeInsets.only(left:kIsWeb?width*0.032:  width * 0.034),
          child: IconButton(onPressed: (){
            Navigator.of(context).pop();
          }, icon: Icon(Icons.arrow_back_ios,color: Colors.black,)),
        ),
        title: Text("Starred Messages"),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getStarredMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading messages",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No Starred Messages Yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          var messages = snapshot.data!;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              var messageText = message['message'] ?? "No text available";
              var senderName = message['sender'] ?? "Unknown Sender";
              var timestamp = message['timestamp'] != null
                  ? (message['timestamp'] as Timestamp).toDate()
                  : DateTime.now();
              var groupName = message['groupName'] ?? "Unknown Group";

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Group: $groupName",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      senderName,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 5),
                    Text(
                      messageText,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.star, color: Colors.yellow),
                          SizedBox(width: 3),
                          Text(
                            "${timestamp.hour}:${timestamp.minute}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
