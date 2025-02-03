// import 'package:chatapp/models/Group.dart';
// import 'package:flutter/material.dart';
import 'package:chatapp/Pages/ChatPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDescription.dart';
import 'package:chatapp/models/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/users_services.dart';
import 'package:flutter/services.dart';

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
  Set<String> selectedMessages = {}; // Track selected messages
  bool isSearching = false;
  String searchQuery = "";
  String? replyingToMessage;
  String? copiedMessage;
  String? repliedMessageText;
  String? editedMessageText; // Store text for editing
  String? replyingToMessageId; // Store the message ID for replying

  // Function to send message
  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String userId = _auth.currentUser!.uid;
      List<String> userNameList = await getUserNames([userId]);
      String username = userNameList.isNotEmpty ? userNameList.first : "Unknown";

      // Add message to Firestore
      await _firestore.collection('groups').doc(widget.newGroup.groupId)
          .collection('messages').add({
        'senderUid': userId,
        'sender': username,
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'pinned': false,
        'favorite': false,
        'replyTo': replyingToMessageId,
      });

      _messageController.clear();
      setState(() {
        replyingToMessage = null;
        repliedMessageText = null;
        replyingToMessageId = null;
        editedMessageText = null; // Clear edited message text after sending
      });
    }
  }

  // Function to handle the reply
  void replyToMessage(String message, String messageId) {
    setState(() {
      replyingToMessageId = messageId;
      replyingToMessage = message;
      _messageController.text = "Replying to: $message\n";
    });
  }

  // Function to handle edit
  void editMessage(String message, String messageId) {
    setState(() {
      editedMessageText = message;
      _messageController.text = message; // Set message text to the input field for editing
      selectedMessages.clear(); // Clear any selected messages
    });
  }

  // Function to start the search
  void startSearch() => setState(() => isSearching = true);

  // Function to stop the search
  void stopSearch() => setState(() => isSearching = false);

  // Function to handle the action of pinning messages
  void pinMessages() {
    selectedMessages.forEach((messageId) async {
      var docRef = _firestore.collection('groups')
          .doc(widget.newGroup.groupId)
          .collection('messages')
          .doc(messageId);
      var doc = await docRef.get();
      bool isPinned = doc['pinned'] ?? false;
      await docRef.update({'pinned': !isPinned});
    });
    setState(() {
      selectedMessages.clear(); // Clear selected messages after pinning
    });
  }

  // Function to handle the action of favoriting messages
  void favoriteMessages() {
    selectedMessages.forEach((messageId) async {
      var docRef = _firestore.collection('groups')
          .doc(widget.newGroup.groupId)
          .collection('messages')
          .doc(messageId);
      var doc = await docRef.get();
      bool isFavorite = doc['favorite'] ?? false;
      await docRef.update({'favorite': !isFavorite});
    });
    setState(() {
      selectedMessages.clear(); // Clear selected messages after favoriting
    });
  }

  // Function to handle the action of deleting messages
  void deleteMessages() {
    selectedMessages.forEach((messageId) async {
      await _firestore.collection('groups')
          .doc(widget.newGroup.groupId)
          .collection('messages')
          .doc(messageId)
          .delete();
    });
    setState(() {
      selectedMessages.clear(); // Clear selected messages after deleting
    });
  }

  // Function to handle the action of copying messages
  void copyMessage(String message) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Message copied to clipboard'),
    ));
    setState(() {
      selectedMessages.clear(); // Clear selected messages after copying
    });
  }

  // Function to handle long press (to select message)
  void handleMessageLongPress(String messageId) {
    setState(() {
      if (selectedMessages.contains(messageId)) {
        selectedMessages.remove(messageId); // Deselect message if it's already selected
      } else {
        selectedMessages.add(messageId); // Select message if it's not already selected
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.072),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    GroupDescription(groupId: widget.newGroup.groupId!, currentUser: widget.currentUser)));
          },
          child: AppBar(
            title: selectedMessages.isNotEmpty
                ? Text("${selectedMessages.length} selected",style:TextStyle(color:Colors.white))
                : isSearching
                ? TextField(
              autofocus: true,
              decoration: InputDecoration(
                  hintText: "Search messages"),
              onChanged: (query) => setState(() => searchQuery = query),
            )
                : Text(widget.newGroup.groupName,
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
            actions: [
              if (selectedMessages.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.push_pin, color: Colors.white),
                  onPressed: pinMessages,
                ),
                IconButton(
                  icon: const Icon(Icons.star, color: Colors.white),
                  onPressed: favoriteMessages,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: deleteMessages,
                ),
                // Display 3 dots when messages are selected
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'reply') {
                      // Perform reply action on selected message
                      String messageId = selectedMessages.first; // Using the first selected message as an example
                      var messageText = 'Replying to message';
                      replyToMessage(messageText, messageId);
                    } else if (value == 'edit') {
                      // Perform edit action on selected message
                      String messageId = selectedMessages.first;
                      var messageText = 'Edit message';
                      editMessage(messageText, messageId);
                    } else if (value == 'copy') {
                      // Perform copy action on selected message
                      String messageId = selectedMessages.first;
                      var messageText = 'Copy message text';
                      copyMessage(messageText);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'reply',
                      child: ListTile(
                        leading: Icon(Icons.reply),
                        title: Text("Reply"),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text("Edit"),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'copy',
                      child: ListTile(
                        leading: Icon(Icons.content_copy),
                        title: Text("Copy"),
                      ),
                    ),
                  ],
                ),
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
        ),
      ),
      body: Column(
        children: [
          if (repliedMessageText != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.grey[200],
                child: Row(
                  children: [
                    Icon(Icons.reply, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Replying to:',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              repliedMessageText!,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                    bool isSelected = selectedMessages.contains(message.id); // Check if message is selected

                    return GestureDetector(
                      onLongPress: () {
                        handleMessageLongPress(message.id);
                      },
                      child: Container(
                        color: isSelected ? Colors.grey[200] : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (message['replyTo'] != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.reply, color: Colors.blue),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          message['message'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.black : Colors.grey[300],
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

  // Function to retrieve message text by message ID
  Future<String> getMessageTextById(String messageId) async {
    DocumentSnapshot messageDoc = await _firestore.collection('groups')
        .doc(widget.newGroup.groupId)
        .collection('messages')
        .doc(messageId)
        .get();

    return messageDoc['message'] ?? ''; // Return the actual message content
     }
}