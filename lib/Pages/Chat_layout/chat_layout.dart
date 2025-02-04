import 'package:chatapp/Pages/Chat_layout/ContectInfo.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:chatapp/services/users_services.dart';

import 'ChatPage.dart';
import 'ContectInfo.dart';
import 'UserInfoPage.dart';

class ChatLayout extends StatefulWidget {
  final CustomClass currentUser;
  final user;
  final DocumentReference<Map<String, dynamic>> databaseRef;

  const ChatLayout(
      {required this.currentUser,
      required this.user,
      required this.databaseRef});

  @override
  State<ChatLayout> createState() => _ChatLayoutState();
}

class _ChatLayoutState extends State<ChatLayout> {
  List messages = [];

  Future<void> sendMessage(String message) async {
    final timestamp = Timestamp.now();

    print('chat db ref here ${widget.databaseRef}');
    await widget.databaseRef.collection("messages").add({
      "sentBy": widget.currentUser.uid,
      "sentTo": widget.user['uid'],
      "message": message,
      "timestamp": timestamp,
      "deliveredAt": timestamp, // Delivery time
      "readAt": null, // Read time
      "seen": false,
    });
  }

  Future<void> fetchMessagesByCurrentUser() async {
    print('Fetching messages...');

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
          "seen": false, //
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
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController message = new TextEditingController();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        backgroundColor: Color(0xFF242935),
        leading: Padding(
          padding: EdgeInsets.only(left: width * 0.064),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              height: width * 0.045,
              width: width * 0.035,
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: width * 0.019),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: width * 0.044,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ContectInfo(currentUser:widget.user['firstName'])));
          },
          child: Text(widget.user['firstName'],
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w500)),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.video_call,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.call,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (messages.isNotEmpty)
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(top: height * 0.12),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          bool x = messages[index]['sentBy'] ==
                              widget.currentUser.uid;
                          bool seenStatus =
                              (messages[index].data() as Map<String, dynamic>)
                                      .containsKey('seen')
                                  ? messages[index]['seen']
                                  : false;

                          bool isEdited =
                              messages[index].data().containsKey('edited') &&
                                  messages[index]['edited'];

                          return GestureDetector(
                            onLongPress: () => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SimpleDialog(
                                  children: [
                                    SimpleDialogOption(
                                      child: Text("Copy"),
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                              text: messages[index]['message']),
                                        );
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Message copied to clipboard")),
                                        );
                                      },
                                    ),
                                    Divider(),
                                    SimpleDialogOption(
                                      child: Text("Forward"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        // Example: Navigate to a forward message screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              currentUser: widget.currentUser,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Divider(),
                                    SimpleDialogOption(
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UserInfoPage(
                                                    messageData: messages[index].data() as Map<String, dynamic>,
                                                    deliveredAt: messages[index]['deliveredAt'],
                                                    readAt: messages[index]['readAt'],
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.info,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Divider(),
                                    SimpleDialogOption(
                                      child: Text("Edit"),
                                      onPressed: () async {
                                        final TextEditingController
                                            editController =
                                            TextEditingController(
                                          text: messages[index]['message'],
                                        );

                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Edit Message"),
                                              content: TextFormField(
                                                controller: editController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "Enter updated message",
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    final updatedMessage =
                                                        editController.text
                                                            .trim();
                                                    if (updatedMessage
                                                        .isNotEmpty) {
                                                      await editMessage(
                                                          messages[index].id,
                                                          updatedMessage);
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  },
                                                  child: Text("Update"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    Divider(),
                                    SimpleDialogOption(
                                      child: Text("Delete"),
                                      onPressed: () async {
                                        await deleteMessage(messages[index].id);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            child: Column(
                              crossAxisAlignment: x
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                ChatBubble(
                                  clipper: ChatBubbleClipper1(
                                      type: x
                                          ? BubbleType.sendBubble
                                          : BubbleType.receiverBubble),
                                  alignment: x
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: width * 0.012,
                                      vertical: height * 0.012),
                                  backGroundColor: x
                                      ? Color(0xFF2C313F)
                                      : Color(0xFF995BF8).withOpacity(0.3),
                                  child: Container(
                                    constraints:
                                        BoxConstraints(maxWidth: width * 0.7),
                                    child: Text(
                                      messages[index]['message'],
                                      style: TextStyle(
                                          fontFamily: 'Raleway',
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4), // Small gap

                                if (x) // Only show for sent messages
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: width * 0.02),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (isEdited) // Show green tick if the message is edited
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Colors.green,
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
                        itemCount: messages.length,
                      ),
                    )),
              /*Expanded(
                    flex: 3,
                    child: Padding(
                      padding:  EdgeInsets.only(top:height*0.12),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          bool x =
                              messages[index]['sentBy'] == widget.currentUser.uid;
                          return ChatBubble(
                            clipper: ChatBubbleClipper1(
                                type: x
                                    ? BubbleType.sendBubble
                                    : BubbleType.receiverBubble),
                            alignment: x ? Alignment.topRight : Alignment.topLeft,
                            margin: EdgeInsets.symmetric(
                                horizontal: width * 0.012,
                                vertical: height * 0.012),
                            backGroundColor: x
                                ? Color(0xFF2C313F)
                                : Color(0xFF995BF8).withOpacity(0.3),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: width * 0.7),
                              child: Text(
                                messages[index]['message'],
                                style: TextStyle(
                                    fontFamily: 'Raleway', color: Colors.white),
                              ),
                            ),
                          );
                        },
                        itemCount: messages.length,
                      ),
                    )),*/
              Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.042,
                            vertical: height * 0.012),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                color: Colors.grey.shade300,
                                width: width * 0.001),
                          ),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: message,
                          decoration: InputDecoration(
                              hintText: "Type a message",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      messages = [];
                                    });
                                    await sendMessage(message.text.trim());
                                    fetchMessagesByCurrentUser();
                                    message.clear();
                                  },
                                  icon: Icon(
                                    Icons.send,
                                    color: Color(0xFF00A884),

                                  ))),
                        ),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
