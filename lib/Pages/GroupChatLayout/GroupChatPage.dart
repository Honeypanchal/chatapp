// import 'package:chatapp/models/Group.dart';
// import 'package:flutter/material.dart';
import 'package:chatapp/Pages/ChatPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDescription.dart';
import 'package:chatapp/models/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/users_services.dart';

class Groupchatpage extends StatefulWidget {
  final Group newGroup;
  final String currentUser;

  const Groupchatpage({super.key, required this.newGroup,required this.currentUser});

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
      String username =
          userNameList.isNotEmpty ? userNameList.first : "Unknown";

      await _firestore
          .collection('groups')
          .doc(widget.newGroup.groupId)
          .collection('messages')
          .add({
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(width, height * 0.072),
          child: GestureDetector(
            onTap: () {
              Future.delayed(Duration(seconds: 3));
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      GroupDescription(groupId: widget.newGroup.groupId!,currentUser:widget.currentUser)));
            },
            child: AppBar(
              title: selectedMessages.isNotEmpty
                  ? Text("${selectedMessages.length} selected")
                  : isSearching
                      ? TextField(
                          autofocus: true,
                          decoration: const InputDecoration(
                              hintText: "Search messages"),
                          onChanged: (query) =>
                              setState(() => searchQuery = query),
                        )
                      : Text(widget.newGroup.groupName,
                          style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black,
              actions: [
                if (selectedMessages.isNotEmpty) ...[
                  IconButton(
                      icon: const Icon(Icons.push_pin, color: Colors.white),
                      onPressed: togglePinnedForSelected),
                  IconButton(
                      icon: const Icon(Icons.star, color: Colors.white),
                      onPressed: toggleFavoriteForSelected),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: deleteMessages),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () =>
                          setState(() => selectedMessages.clear())),
                ] else ...[
                  if (!isSearching)
                    IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: startSearch),
                  if (isSearching)
                    IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: stopSearch),
                ],
              ],
            ),
          )),
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
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
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
                        RegExp(r'\b' + RegExp.escape(searchQuery) + r'\b',
                                caseSensitive: false)
                            .hasMatch(message['message']);

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          selectedMessages.contains(message.id)
                              ? selectedMessages.remove(message.id)
                              : selectedMessages.add(message.id);
                        });
                      },
                      child: Container(
                        color: selectedMessages.contains(message.id)
                            ? Colors.lightBlue.withOpacity(0.3)
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
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
                                        Icon(Icons.push_pin,
                                            size: 14, color: Colors.yellow),
                                        SizedBox(width: 5),
                                        Text("Pinned",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.yellow)),
                                      ],
                                    ),
                                  Text(
                                    message['message'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                      backgroundColor: isSearched
                                          ? Colors.yellow.withOpacity(0.5)
                                          : null,
                                    ),
                                  ),
                                  if (isFavorite)
                                    Icon(Icons.star,
                                        size: 14, color: Colors.orange),
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
