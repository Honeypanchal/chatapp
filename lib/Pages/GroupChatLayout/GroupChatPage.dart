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

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String userId = _auth.currentUser!.uid;
      var user = widget.newGroup.participants.firstWhere(
            (member) => member['uid'] == userId,
        orElse: () => {'firstName': 'Unknown'},
      );
      String username = user['firstName'];
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

  void toggleSelection(String messageId) {
    setState(() {
      if (selectedMessages.contains(messageId)) {
        selectedMessages.remove(messageId);
      } else {
        selectedMessages.add(messageId);
      }
    });
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
    setState(() {
      selectedMessages.clear();
    });
  }

  void togglePinned() async {
    for (String messageId in selectedMessages) {
      var messageRef = _firestore
          .collection('groups')
          .doc(widget.newGroup.groupId)
          .collection('messages')
          .doc(messageId);
      var messageSnapshot = await messageRef.get();
      bool isPinned = messageSnapshot['pinned'] ?? false;
      await messageRef.update({'pinned': !isPinned});
    }
    setState(() {
      selectedMessages.clear();
    });
  }

  void toggleFavorite() async {
    for (String messageId in selectedMessages) {
      var messageRef = _firestore
          .collection('groups')
          .doc(widget.newGroup.groupId)
          .collection('messages')
          .doc(messageId);
      var messageSnapshot = await messageRef.get();
      bool isFavorite = messageSnapshot['favorite'] ?? false;
      await messageRef.update({'favorite': !isFavorite});
    }
    setState(() {
      selectedMessages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedMessages.isNotEmpty
          ? AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("${selectedMessages.length} selected"),
        actions: [
          IconButton(icon: const Icon(Icons.star), onPressed: toggleFavorite),
          IconButton(icon: const Icon(Icons.push_pin), onPressed: togglePinned),
          IconButton(icon: const Icon(Icons.delete), onPressed: deleteMessages),
        ],
      )
          : AppBar(
        title: Text(widget.newGroup.groupName),
        backgroundColor: Colors.blue,
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isMe = message['senderUid'] == _auth.currentUser!.uid;
                    bool isSelected = selectedMessages.contains(message.id);
                    bool isPinned = message['pinned'] ?? false;
                    bool isFavorite = message['favorite'] ?? false;

                    return GestureDetector(
                      onLongPress: () => toggleSelection(message.id),
                      child: Container(
                        color: isSelected ? Colors.lightBlue.withOpacity(0.3) : Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  message['message'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              // Positioning icons below the message
                              if (isPinned || isFavorite)
                                Positioned(
                                  bottom: -4, // Adjust as needed to position it just below the message
                                  right: 5,
                                  child: Row(
                                    children: [
                                      if (isPinned)
                                        Icon(
                                          Icons.push_pin,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                      if (isFavorite)
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 16,
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
