// import 'package:chatapp/models/Group.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class Groupchatpage extends StatefulWidget {
//   final Group newGroup;
//   const Groupchatpage({super.key, required this.newGroup});
//
//   @override
//   State<Groupchatpage> createState() => _GroupchatpageState();
// }
//
// class _GroupchatpageState extends State<Groupchatpage> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Set<String> selectedMessages = {};
//
//   void sendMessage() async {
//     if (_messageController.text.trim().isNotEmpty) {
//       String userId = _auth.currentUser!.uid;
//       var user = widget.newGroup.participants.firstWhere(
//             (member) => member['uid'] == userId,
//         orElse: () => {'firstName': 'Unknown'},
//       );
//       String username = user['firstName'];
//       await _firestore.collection('groups').doc(widget.newGroup.groupId).collection('messages').add({
//         'senderUid': userId,
//         'sender': username,
//         'message': _messageController.text.trim(),
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       _messageController.clear();
//     }
//   }
//
//   void toggleSelection(String messageId) {
//     setState(() {
//       if (selectedMessages.contains(messageId)) {
//         selectedMessages.remove(messageId);
//       } else {
//         selectedMessages.add(messageId);
//       }
//     });
//   }
//
//   void deleteMessages() async {
//     for (String messageId in selectedMessages) {
//       await _firestore
//           .collection('groups')
//           .doc(widget.newGroup.groupId)
//           .collection('messages')
//           .doc(messageId)
//           .delete();
//     }
//     setState(() {
//       selectedMessages.clear();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: selectedMessages.isNotEmpty
//           ? AppBar(
//         backgroundColor: Colors.blueGrey,
//         title: Text("${selectedMessages.length} selected"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.star),
//             onPressed: () {}, // Add favorite functionality
//           ),
//           IconButton(
//             icon: const Icon(Icons.push_pin),
//             onPressed: () {}, // Add pin functionality
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: deleteMessages,
//           ),
//         ],
//       )
//           : AppBar(
//         title: Text(widget.newGroup.groupName),
//         backgroundColor: Colors.blue,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: _firestore
//                   .collection('groups')
//                   .doc(widget.newGroup.groupId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     var message = snapshot.data!.docs[index];
//                     bool isMe = message['senderUid'] == _auth.currentUser!.uid;
//                     bool isSelected = selectedMessages.contains(message.id);
//
//                     return GestureDetector(
//                       onLongPress: () => toggleSelection(message.id),
//                       child: Align(
//                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? Colors.lightBlue.withOpacity(0.5)
//                                 : (isMe ? Colors.blue : Colors.grey[300]),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             crossAxisAlignment:
//                             isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 message['sender'],
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: isMe ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 message['message'],
//                                 style: TextStyle(
//                                   color: isMe ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: "Type a message",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.blue),
//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:chatapp/models/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/users.dart';

class Groupchatpage extends StatefulWidget {
  final Group newGroup;
  const Groupchatpage({super.key, required this.newGroup});

  @override
  State<Groupchatpage> createState() => _GroupchatpageState();
}

class _GroupchatpageState extends State<Groupchatpage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> selectedMessages = {};
  bool isSearching = false;
  String searchQuery = "";

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String userId = _auth.currentUser!.uid;
      List<String> userNameList = await getUserNames([userId]);
      String username = userNameList.isNotEmpty ? userNameList.first : "Unknown";

      await _firestore.collection('groups').doc(widget.newGroup.groupId).collection('messages').add({
        'senderUid': userId,
        'sender': username,
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'pinned': false,
        'favorite': false,
      });

      _messageController.clear();
    }
  }

  void togglePinnedForSelected() async {
    for (String messageId in selectedMessages) {
      DocumentReference messageRef = _firestore
          .collection('groups')
          .doc(widget.newGroup.groupId)
          .collection('messages')
          .doc(messageId);
      DocumentSnapshot messageDoc = await messageRef.get();
      bool currentStatus = messageDoc['pinned'] ?? false;
      await messageRef.update({'pinned': !currentStatus});
    }
    setState(() => selectedMessages.clear());
  }

  void toggleFavoriteForSelected() async {
    for (String messageId in selectedMessages) {
      DocumentReference messageRef = _firestore
          .collection('groups')
          .doc(widget.newGroup.groupId)
          .collection('messages')
          .doc(messageId);
      DocumentSnapshot messageDoc = await messageRef.get();
      bool currentStatus = messageDoc['favorite'] ?? false;
      await messageRef.update({'favorite': !currentStatus});
    }
    setState(() => selectedMessages.clear());
  }

  void deleteMessages() async {
    for (String messageId in selectedMessages) {
      await _firestore
          .collection('groups')
          .doc(widget.newGroup.groupId)
          .collection('messages')
          .doc(messageId)
          .delete();
    }
    setState(() => selectedMessages.clear());
  }

  void startSearch() => setState(() => isSearching = true);
  void stopSearch() => setState(() => isSearching = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectedMessages.isNotEmpty
            ? Text("${selectedMessages.length} selected")
            : isSearching
            ? TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Search messages"),
          onChanged: (query) => setState(() => searchQuery = query),
        )
            : Text(widget.newGroup.groupName),
        backgroundColor: Colors.blue,
        actions: [
          if (selectedMessages.isNotEmpty) ...[
            IconButton(icon: const Icon(Icons.push_pin, color: Colors.yellow), onPressed: togglePinnedForSelected),
            IconButton(icon: const Icon(Icons.star, color: Colors.orange), onPressed: toggleFavoriteForSelected),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: deleteMessages),
            IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => selectedMessages.clear())),
          ] else ...[
            if (!isSearching) IconButton(icon: const Icon(Icons.search), onPressed: startSearch),
            if (isSearching) IconButton(icon: const Icon(Icons.close), onPressed: stopSearch),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.newGroup.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderUid'] == _auth.currentUser!.uid;
                    bool isPinned = message['pinned'] ?? false;
                    bool isFavorite = message['favorite'] ?? false;
                    bool isSearched = searchQuery.isNotEmpty &&
                        RegExp(r'\b' + RegExp.escape(searchQuery) + r'\b', caseSensitive: false).hasMatch(message['message']);

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          selectedMessages.contains(message.id)
                              ? selectedMessages.remove(message.id)
                              : selectedMessages.add(message.id);
                        });
                      },
                      child: Container(
                        color: selectedMessages.contains(message.id) ? Colors.lightBlue.withOpacity(0.3) : Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isPinned)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.push_pin, size: 14, color: Colors.yellow),
                                        SizedBox(width: 5),
                                        Text("Pinned", style: TextStyle(fontSize: 12, color: Colors.yellow)),
                                      ],
                                    ),
                                  Text(
                                    message['message'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                      backgroundColor: isSearched ? Colors.yellow.withOpacity(0.5) : null,
                                    ),
                                  ),
                                  if (isFavorite) Icon(Icons.star, size: 14, color: Colors.orange),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
