import 'package:chatapp/Pages/ChatLayout/ContectInfo.dart';
import 'package:chatapp/Pages/ChatLayout/UserInfoPage.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';


class ChatLayout extends StatefulWidget {

  final CustomClass currentUser;
  final user;
  final DocumentReference<Map<String, dynamic>> databaseRef;

  const ChatLayout({
    required this.currentUser,
    required this.user,
    required this.databaseRef,
  });

  @override
  State<ChatLayout> createState() => _ChatLayoutState();
}

class _ChatLayoutState extends State<ChatLayout> {
  List messages = [];
  ScrollController scrollController = ScrollController();
  late Stream<QuerySnapshot> messageStream;
  String? replyToMessage;
  String? replyToSender;
  bool isAppBarForSelectedMessages =
  false; // Check if the app bar should show options for selected messages
  List<String> selectedMessages = []; // To store selected message ids
  // TextEditingController message=TextEditingController();

  // Function to handle message selection (add/remove from selectedMessages)
  void toggleMessageSelection(String messageId) {
    setState(() {
      if (selectedMessages.contains(messageId)) {
        selectedMessages.remove(messageId);
      } else {
        selectedMessages.add(messageId);
      }

      isAppBarForSelectedMessages = selectedMessages.isNotEmpty;
    });
  }

  // Function to handle pinning a message (store it in database)
  Future<void> pinMessages() async {
    for (String messageId in selectedMessages) {
      await widget.databaseRef.collection("messages").doc(messageId).update({
        "isPinned": true, // Example field to indicate a pinned message
      });
    }

    setState(() {
      selectedMessages.clear();
      isAppBarForSelectedMessages = false;
    });
  }

  // Function to handle marking a message as favorite
  Future<void> favoriteMessages() async {
    for (String messageId in selectedMessages) {
      await widget.databaseRef.collection("messages").doc(messageId).update({
        "isFavorite": true, // Example field to indicate a favorite message
      });
    }

    setState(() {
      selectedMessages.clear();
      isAppBarForSelectedMessages = false;
    });
  }

  Future<void> sendMessage(String message) async {
    final timestamp = Timestamp.now();
    await widget.databaseRef.collection("messages").add({
      "sentBy": widget.currentUser.uid,
      "sentTo": widget.user['uid'],
      "message": message,
      "replyTo": replyToMessage,
      "replyToSender": replyToSender,
      "timestamp": timestamp,
      "deliveredAt": timestamp, // Delivery time
      "readAt": null, // Read time
      "seen": false,
    });
    setState(() {
      replyToMessage = null;
      replyToSender = null;
    });
  }

  Future<void> fetchMessagesByCurrentUser() async {
    widget.databaseRef
        .collection("messages")
        .snapshots()
        .listen((QuerySnapshot event) {
      setState(() {
        messages.clear();
        messages.addAll(event.docs);
        messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      });

      for (var doc in event.docs) {
        Map<String, dynamic> messageData = doc.data() as Map<String, dynamic>;

        if (messageData['sentTo'] == widget.currentUser.uid &&
            messageData['seen'] == false) {
          print('Updating seen status for message: ${doc.id}');
          widget.databaseRef.collection("messages").doc(doc.id).update({
            "seen": true,
            "readAt": Timestamp.now(),
          }).then((_) {
            print('Message marked as seen: ${doc.id}');
          }).catchError((error) {
            print('Error updating seen status: $error');
          });
        }
      }
    });
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await widget.databaseRef.collection("messages").doc(messageId).delete();
      setState(() {
        messages.removeWhere((msg) => msg.id == messageId);
      });
      print("Message deleted successfully.");
    } catch (e) {
      print("Failed to delete message: $e");
    }
  }

  Future<void> editMessage(String messageId, String updatedMessage) async {
    try {
      await widget.databaseRef.collection("messages").doc(messageId).update({
        "message": updatedMessage,
        "timestamp": Timestamp.now(),
        // Optional: Update the timestamp to reflect the edit time
        "edited": true,
      });
      print("Message updated successfully.");
    } catch (e) {
      print("Failed to update message: $e");
    }
  }

  Future<Map<String, dynamic>> fetchUserInfo() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user['uid'])
        .get();

    return userDoc.data() as Map<String, dynamic>;
  }

  Future<void> updateOldMessages() async {
    QuerySnapshot snapshot =
    await widget.databaseRef.collection("messages").get();
    for (var doc in snapshot.docs) {
      if (!(doc.data() as Map<String, dynamic>).containsKey('seen')) {
        await widget.databaseRef.collection("messages").doc(doc.id).update({
          "seen": false, //  Add 'seen' field to old messages
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMessagesByCurrentUser();
    updateOldMessages();

    // Update last seen when user opens chat
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currentUser.uid)
        .update({
      "lastSeen": "${DateTime.now().hour}:${DateTime.now().minute}",
    });

    messageStream = widget.databaseRef
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController message = TextEditingController();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 246, 241, 235),
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.072),
        child: AppBar(


          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),

          title: isAppBarForSelectedMessages
              ? Text("${selectedMessages.length} selected", style: TextStyle(color: Colors.white),)
              : GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContectInfo(
                        currentUser: widget.user['firstName'],
                        email: widget.user['email'],
                      )));
            },
            child: Text(
              widget.user['firstName'],
              style: TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Colors.white,
          actions: [
            if (isAppBarForSelectedMessages) ...[
              // Pin button
              IconButton(
                icon: const Icon(Icons.push_pin, color: Colors.white),
                onPressed: pinMessages,
              ),
              // Favorite button
              IconButton(
                icon: const Icon(Icons.star, color: Colors.white),
                onPressed: favoriteMessages,
              ),
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      int index = messages.indexWhere((message) =>
                          selectedMessages
                              .contains(message.id)); // Find index dynamically
                      if (index != -1) {
                        deleteMessage(messages[index].id);
                      }
                    },
                  );
                },
              ),
              // 3 dots popup menu button
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  int index = messages.indexWhere((message) => selectedMessages
                      .contains(message.id)); // Find index dynamically
                  String messageId = selectedMessages
                      .first; // Using the first selected message as an example
                  if (value == 'reply') {
                    // Handle reply action
                  }
                  else if (value == 'edit') {
                    // Handle edit action

                    final TextEditingController editController =
                    TextEditingController(text: messages[index]['message']);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Edit Message"),
                          content: TextField(
                            controller: editController,
                            decoration:
                            const InputDecoration(labelText: "Message"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                final updatedMessage =
                                editController.text.trim();
                                if (updatedMessage.isNotEmpty) {
                                  await editMessage(
                                      messages[index].id, updatedMessage);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text("Save"),
                            ),
                          ],
                        );
                      },
                    );
                  }

                  else if (value == 'copy') {
                    // Handle copy action
                    Clipboard.setData(
                        ClipboardData(text: messages[index]['message']));
                  }
                  else if (value == 'info') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserInfoPage(
                              messageData:
                              messages[index].data()
                              as Map<String, dynamic>,
                              deliveredAt: messages[index]
                              ['deliveredAt'],
                              readAt: messages[index]
                              ['readAt'],
                            ),
                      ),
                    );
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
                  PopupMenuItem(
                    value: 'info',
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text("Info"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      body: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          // if (messages.isNotEmpty)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: messages.isNotEmpty
                  ? ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final messageData =
                  messages[index].data() as Map<String, dynamic>;
                  final isCurrentUser =
                      messageData['sentBy'] == widget.currentUser.uid;
                  final repliedMessage = messageData['replyTo'];
                  final repliedSender = messageData['replyToSender'];
                  final messageId = messages[index].id;

                  bool x =
                      messages[index]['sentBy'] == widget.currentUser.uid;
                  bool seenStatus =
                  messageData.containsKey('seen') ? messageData['seen'] : false;

                  bool isEdited =
                  messageData.containsKey('edited') ? messageData['edited'] : false;

                  return GestureDetector(
                    onLongPress: () {
                      toggleMessageSelection(messageId);
                    },

                    onHorizontalDragEnd: (details) {
                      setState(() {
                        replyToMessage = messageData['message'];
                        replyToSender = isCurrentUser
                            ? "You"
                            : widget.user['firstName'];
                      });
                    },
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (repliedMessage != null)
                          Container(
                            margin:
                            const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  repliedSender ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  repliedMessage,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Container(

                          margin: EdgeInsets.symmetric(
                            horizontal: width * 0.02,
                            vertical: height * 0.01,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ?Color.fromARGB(255, 213, 252, 208)
                                : Colors.white,

                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: isCurrentUser ? Radius.circular(16) : Radius.circular(16),
                              bottomRight: isCurrentUser ?  Radius.circular(16) : Radius.circular(16),
                            ),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 50,
                            maxWidth: width * 0.6,
                            ),

                          child: Text(
                            messages[index]['message'],
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              color: isCurrentUser ? Colors.black : Colors.black87,
                            ),
                          ),
                        ),



                        SizedBox(height: 4), // Small gap

                        if (x) // Only show for sent messages
                          Padding(
                            padding: EdgeInsets.only(right: width * 0.02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isEdited) // Show green tick if the message is edited
                                  if (messages[index]['edited'] == true) // Show "edited" label if edited
                                    const Text(
                                      "edited",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                Icon(
                                  seenStatus
                                      ? Icons.done_all
                                      : Icons.check,
                                  size: 16,
                                  color: seenStatus
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              )
                  : const Center(
                child: Text("No messages yet."),
              ),
            ),
          ),
          if (replyToMessage != null)
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          replyToSender ?? "Unknown",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        Text(
                          replyToMessage!,
                          style: const TextStyle(color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => setState(() {
                      replyToMessage = null;
                      replyToSender = null;
                    }),
                  ),
                ],
              ),
            ),
          // Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Container(
          //       padding: EdgeInsets.symmetric(
          //           horizontal: width * 0.042, vertical: height * 0.012),
          //       decoration: BoxDecoration(
          //         border: Border(
          //           top: BorderSide(
          //               color: Colors.grey.shade300, width: width * 0.001),
          //         ),
          //         color: Colors.white,
          //       ),
          //       child: TextFormField(
          //         controller: message,
          //         decoration: InputDecoration(
          //             hintText: "Type a message",
          //             hintStyle: TextStyle(color: Colors.grey),
          //             border: InputBorder.none,
          //             suffixIcon: IconButton(
          //                 onPressed: () async {
          //                   setState(() {
          //                     messages = [];
          //                   });
          //                   await sendMessage(message.text.trim());
          //                   fetchMessagesByCurrentUser();
          //                   // ----------
          //                   message.clear();
          //                 },
          //                 icon: Icon(
          //                   Icons.send,
          //                   color: Color(0xFF00A884),
          //                 ))),
          //       ),
          //     ))
          Padding(
            padding: const EdgeInsets.only(right: 10,bottom: 10,left: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                // border: Border.all(color: Colors.grey, width: 1),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    // onTap: () => Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => CreatePollPage(
                    //       sendMessage: sendMessage,
                    //     ),
                    //   ),
                    // ),
                    child: Icon(Icons.poll, color: Colors.grey,size: width*0.07,),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: message,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),

                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        messages = [];
                      });
                      await sendMessage(message.text.trim());
                      fetchMessagesByCurrentUser();
                      // ----------
                      message.clear();
                    },
                    child: Icon(Icons.send, color: Colors.grey),
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

