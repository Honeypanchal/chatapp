import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

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
      "seen": false,
    });
  }
  /*Future<void> fetchMessagesByCurrentUser() async {
    print('Fetching messages...');

    // Listen to real-time updates
    widget.databaseRef.collection("messages").snapshots().listen((QuerySnapshot event) async {
      print("Processing message changes...");

      setState(() {
        messages.clear();

        // Loop through the documents and extract data
        messages.addAll(event.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Ensure 'seen' field exists
          data['seen'] = data.containsKey('seen') ? data['seen'] : false;
          return data;
        }).toList());

        // Sort messages by timestamp
        messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      });

      // Mark unread messages as seen
      await widget.databaseRef.collection("messages")
          .where('sentTo', isEqualTo: widget.currentUser.uid)
          .where('seen', isEqualTo: false)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({"seen": true}); // Mark message as seen
        });
      });
    });
  }*/

  /*Future<void> fetchMessagesByCurrentUser() async {
    print('Fetching messages...');

    // Listen to real-time updates
    final newDB = widget.databaseRef.collection("messages").snapshots();

    newDB.listen((QuerySnapshot event) async {
      // This will trigger every time there's a change to the collection
      event.docChanges.forEach((change) async {
        print("Processing message change...");

        // Directly use the event's docs, no need to fetch again
        setState(() {
          // Map over the documents, and ensure each has a 'seen' field
          messages.clear();
          messages.addAll(event.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['seen'] = data.containsKey('seen') ? data['seen'] : false; // Default to false if 'seen' is missing
            return data;
          }).toList());

          // Sort the messages by timestamp to display in order
          messages.sort((a, b) {
            return a['timestamp'].compareTo(b['timestamp']);
          });
        });

        // Optionally update 'seen' field for unread messages when the current user reads them
        await widget.databaseRef.collection("messages")
            .where('sentTo', isEqualTo: widget.currentUser.uid)
            .where('seen', isEqualTo: false)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.update({"seen": true}); // Mark message as seen
          });
        });
      });
    });
  }*/
  // original
  /*Future<void> fetchMessagesByCurrentUser() async {
    print('here');
    final newDB = widget.databaseRef.collection("messages").snapshots();
    if (newDB.length == 0) {
      print('No data present in db');
    }
    newDB.listen((QuerySnapshot event) async {
      event.docChanges.forEach((change) async {
        print("triggered");
        final userMessages =
            await widget.databaseRef.collection("messages").get();

        setState(() {
          messages.clear();
          messages.addAll(userMessages.docs);
          messages.sort((a, b) {
            return a['timestamp'].compareTo(b['timestamp']);
          });
        });
      });
    });
  }*/

  Future<void> fetchMessagesByCurrentUser() async {
    widget.databaseRef.collection("messages").snapshots().listen((event) {
      setState(() {
        messages.clear();
        messages.addAll(event.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id; // Store document ID for updating
          data['seen'] = data.containsKey('seen') ? data['seen'] : false;
          return data;
        }).where((message) {
          // Ensure only messages related to the current user are fetched
          return message['sentBy'] == widget.currentUser.uid ||
              message['sentTo'] == widget.user['uid'];
        }).toList());

        // Sort messages by timestamp
        messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      });

      //**Mark unread messages as seen when the current user reads them**
      event.docs.forEach((doc) {
        if ((doc['sentTo'] == widget.user['uid'] ||
            doc['sentBy'] == widget.currentUser.uid)
            && !doc['seen']) {
          doc.reference.update({"seen": true});
        }
      });
    });
  }

  /*Future<void> fetchMessagesByCurrentUser() async {
    print('here');
    final newDB = widget.databaseRef.collection("messages").snapshots();
    if (newDB.length == 0) {
      print('No data present in db');
    }
    newDB.listen((QuerySnapshot event) async {
      event.docChanges.forEach((change) async {
        print("triggered");
        final userMessages =
            await widget.databaseRef.collection("messages").get();

        setState(() {
          messages.clear();
          messages.addAll(userMessages.docs.map((doc) {
            var data = doc.data();
            data['seen'] = data.containsKey('seen') ? data['seen'] : false;
            return data;
          }).toList());


          messages.sort((a, b) {
            return a['timestamp'].compareTo(b['timestamp']);
          });
        });
        // Update the 'seen' status when the current user reads the message
        await widget.databaseRef
            .collection("messages")
            .where('sentTo', isEqualTo: widget.currentUser.uid)
            .where('seen', isEqualTo: false) // Get unread messages
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.update({"seen": true}); // Mark message as seen
          });
        });
      });
    });
  }*/

  // Call this method when the message is visible on the screen or when user scrolls
  Future<void> markMessageAsSeen(DocumentReference messageRef) async {
    await messageRef.update({
      "seen": true, // Update the "seen" field to true when message is viewed
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMessagesByCurrentUser();
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
        title: Text(widget.user['firstName'],
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w500)),
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
        child: SizedBox(
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
                      // itemCount: messages.length,
                      itemBuilder: (context, index) {
                        bool isSentByCurrentUser = messages[index]['sentBy'] == widget.currentUser.uid;
                        bool seen = messages[index]['seen'];

                      /*itemBuilder: (context, index) {
                        bool x =
                            messages[index]['sentBy'] == widget.currentUser.uid;

                        // Check if the 'seen' field exists, otherwise set it to false
                        bool seen = messages[index].data().containsKey('seen')
                            ? messages[index]['seen']
                            : false;*/

                        return ChatBubble(
                          clipper: ChatBubbleClipper1(
                            type:isSentByCurrentUser ? BubbleType.sendBubble : BubbleType.receiverBubble,
                          ),
                              // original
                              /*type: x
                                  ? BubbleType.sendBubble
                                  : BubbleType.receiverBubble),*/
                          alignment: isSentByCurrentUser ? Alignment.topRight : Alignment.topLeft,
                          margin: EdgeInsets.symmetric(
                              horizontal: width * 0.012,
                              vertical: height * 0.012),
                          backGroundColor: isSentByCurrentUser
                              ? Color(0xFF2C313F)
                              : Color(0xFF995BF8).withOpacity(0.3),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: width * 0.7),
                            child: Column(
                              crossAxisAlignment: isSentByCurrentUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                // Display the message text
                                Text(
                                  messages[index]['message'],
                                  style: TextStyle(
                                      fontFamily: 'Raleway',
                                      color: Colors.white),
                                ),

                                // Show the "Seen" status if the message is seen
                                if (seen) // Show seen status if message is marked as seen
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "Seen",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),

                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: messages.length,
                    ),
                  ),
                ),

              /*Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(top: height * 0.12),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        bool x = messages[index]['sentBy'] == widget.currentUser.uid;
                        return ChatBubble(
                          clipper: ChatBubbleClipper1(
                              type: x ? BubbleType.sendBubble : BubbleType.receiverBubble),
                          alignment: x ? Alignment.topRight : Alignment.topLeft,
                          margin: EdgeInsets.symmetric(horizontal: width * 0.012, vertical: height * 0.012),
                          backGroundColor: x
                              ? Color(0xFF2C313F)
                              : Color(0xFF995BF8).withOpacity(0.3),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: width * 0.7),
                            child: Column(
                              crossAxisAlignment: x ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                // Display the message text
                                Text(
                                  messages[index]['message'],
                                  style: TextStyle(fontFamily: 'Raleway', color: Colors.white),
                                ),
                                // Show the "Seen" status if the message is seen
                                if (messages[index]['seen']) // Show seen status if message is marked as seen
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "Seen",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: messages.length,
                    ),
                  ),
                ),*/

              /*Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(top: height * 0.12),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          bool x = messages[index]['sentBy'] ==
                              widget.currentUser.uid;
                          return ChatBubble(
                            clipper: ChatBubbleClipper1(
                                type: x
                                    ? BubbleType.sendBubble
                                    : BubbleType.receiverBubble),
                            alignment:
                                x ? Alignment.topRight : Alignment.topLeft,
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
                                    fontFamily: 'Raleway', color: Colors.white),
                              ),
                            ),
                          );
                        },
                        itemCount: messages.length,
                      ),
                    )),*/
              /*Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.042, vertical: height * 0.012),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: message,
                        decoration: InputDecoration(
                          hintText: "Type a message",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Color(0xFF995BF8)),
                      onPressed: () async {
                        String text = message.text.trim();
                        if (text.isNotEmpty) {
                          await sendMessage(text);
                          message.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),*/
              // original
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                              color: Color(0xFF995BF8),
                            ))),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
