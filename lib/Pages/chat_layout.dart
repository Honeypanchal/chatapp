import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:image_picker/image_picker.dart';

import '../models/CustomClass.dart';
import 'ChatPage.dart';

class ChatLayout extends StatefulWidget {
  final CustomClass currentUser;
  final user;
  final DocumentReference<Map<String,dynamic>> databaseRef;

  const ChatLayout({required this.currentUser, required this.user,required this.databaseRef});
  const ChatLayout({
    required this.currentUser,
    required this.user,
    required this.databaseRef,
  });

  @override
  State<ChatLayout> createState() => _ChatLayoutState();
}

class _ChatLayoutState extends State<ChatLayout> {


class _ChatLayoutState extends State<ChatLayout> with WidgetsBindingObserver{
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
  Future<void> fetchMessagesByCurrentUser() async {
    print('Fetching messages...');

  Future<void> sendImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final File file = File(pickedFile.path);

      final String fileName = "${widget.currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Reference Firebase Storage location
      final Reference storageRef = FirebaseStorage.instance.ref().child('chat_images/$fileName');
    widget.databaseRef.collection("messages").snapshots().listen((QuerySnapshot event) {
      setState(() {
        messages.clear();
        messages.addAll(event.docs);
        messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      });

      /// ✅ **Fix: Ensure 'seen' field updates when receiver opens chat**
      for (var doc in event.docs) {
        Map<String, dynamic> messageData = doc.data() as Map<String, dynamic>;

        if (messageData['sentTo'] == widget.currentUser.uid && messageData['seen'] == false) {
          print('Updating seen status for message: ${doc.id}');
          widget.databaseRef.collection("messages").doc(doc.id).update({
            "seen": true,
          }).then((_) {
            print('Message marked as seen: ${doc.id}');
          }).catchError((error) {
            print('Error updating seen status: $error');
          });
        }
      }
    });
  }
      // Upload image
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);

      // Get image URL from Firebase Storage
      final String imageUrl = await snapshot.ref.getDownloadURL();

      // Save image metadata to Firestore
      final timestamp = Timestamp.now();
      await widget.databaseRef.collection("messages").add({
        "sentBy": widget.currentUser.uid,
        "sentTo": widget.user['uid'],
        "message": imageUrl,
        "timestamp": timestamp,
      });

      print("Image sent successfully!");
    } catch (e) {
      print("Failed to send image: $e");
  /*Future<void> fetchMessagesByCurrentUser() async {
    print('here');
    final newDB =  widget.databaseRef.collection("messages").snapshots();
    if(newDB.length==0){
      print('No data present in db');
    }
    newDB.listen((QuerySnapshot event) async {
      event.docChanges.forEach((change) async {
        print("triggered");
        final userMessages = await widget.databaseRef.collection("messages")
            .get();
  }

        setState(() {  messages.clear();
        messages.addAll(userMessages.docs);
        print(messages.length);
        messages.sort((a,b){
          return a['timestamp'].compareTo(b['timestamp']);
        });

        for (var doc in event.docs) {
          if (doc['sentTo'] == widget.currentUser.uid &&
              !(doc.data() as Map<String, dynamic>).containsKey('seen')) {
            widget.databaseRef.collection("messages").doc(doc.id).update({
              "seen": true, // 🔹 Mark message as seen when opened
            });
          }
        }
        });
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

  Future<void> fetchMessagesByCurrentUser() async {
    final snapshot = widget.databaseRef.collection("messages").snapshots();
    snapshot.listen((QuerySnapshot event) {
      setState(() {
        messages.clear();
        messages.addAll(event.docs);
        messages.sort((a, b) {
          return a['timestamp'].compareTo(b['timestamp']);
        });
      });
    });
  }*/

  Future<void> updateOldMessages() async {
    QuerySnapshot snapshot = await widget.databaseRef.collection("messages").get();
    for (var doc in snapshot.docs) {
      if (!(doc.data() as Map<String, dynamic>).containsKey('seen')) {
        await widget.databaseRef.collection("messages").doc(doc.id).update({
          "seen": false, // 🔹 Add 'seen' field to old messages
        });
      }
    }
  Future<void> editMessage(String messageId,String updatedMessage) async {
    try {
      await widget.databaseRef.collection("messages").doc(messageId).update({
        "message": updatedMessage,
        "timestamp": Timestamp.now(), // Optional: Update the timestamp to reflect the edit time
      });
      print("Message updated successfully.");
    } catch (e) {
      print("Failed to update message: $e");
    }
  }




final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchMessagesByCurrentUser();
    updateOldMessages();
    WidgetsBinding.instance.addObserver(this);
    setStatus("online");

  }

  void setStatus(String status) async{
    await _firestore.collection('Users').doc(widget.currentUser.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state== AppLifecycleState.resumed){
      //online
      setStatus("online");

    }
    else{
      //offline
      setStatus("offline");

    }
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
        // leading: InkWell(child: Icon(Icons.arrow_back_ios,color: Colors.white,),
        // onTap: (){Navigator.pop(context);},),
        // title: Text(
        //   widget.user['firstName'],
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontFamily: 'Raleway',
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        title: StreamBuilder<DocumentSnapshot>(
         stream: _firestore.collection('Users').doc(widget.user['uid']).snapshots(),
          builder: (context,snapshot){
            if(snapshot.data != null){
              return Column(
                children: [
                  Text(
                  widget.user['firstName'],
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
                  Text(
                    widget.user['status'],
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      // fontSize: 3,
                    ),
                  ),
                // Text(
                //   widget.user['status'],
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontFamily: 'Raleway',
                //     fontWeight: FontWeight.w500,
                //     fontSize: 3,
                //   ),
                // ),
                ],
              );
            }
            else{
              return Container();
            }
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height,
      body:
      SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height*0.9,
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
                          bool x = messages[index]['sentBy'] == widget.currentUser.uid;
                          bool seenStatus = (messages[index].data() as Map<String, dynamic>).containsKey('seen')
                              ? messages[index]['seen']
                              : false;
              Expanded(
                  // flex: 3,
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      bool isSentByCurrentUser =
                          messages[index]['sentBy'] == widget.currentUser.uid;

                      final bool isImageMessage =
                    messages[index].data().containsKey('imageUrl');
//
                      return GestureDetector(
                        // onLongPress: () => showDialog(
                        //   context: context,
                        //   builder: (BuildContext context) {
                        //     return Container(
                        //       child: Column(
                        //         children: [
                        //           TextButton(
                        //             onPressed: () async {
                        //               await deleteMessage(messages[index].id);
                        //               Navigator.of(context).pop();
                        //             },
                        //             child: Text("Delete"),
                        //           ),
                        //           Divider(),
                        //           TextButton(
                        //             onPressed: () async {
                        //               await editMessage(messages[index].id,);
                        //               Navigator.of(context).pop();
                        //             },
                        //             child: Text("Edit"),
                        //           ),
                        //
                        //
                        //         ],
                        //       ),
                        //
                        //     );
                        //
                        //
                        //   },
                        // ),
                        // onLongPress: () => showDialog(
                        //   context: context,
                        //   builder: (BuildContext context) {
                        //     return SimpleDialog(
                        //       children: [
                        //         SimpleDialogOption(
                        //           child: Text("Edit"),
                        //           onPressed: () async {
                        //             final TextEditingController editController = TextEditingController(
                        //               text: messages[index]['message'],
                        //             );
                        //
                        //             await showDialog(
                        //               context: context,
                        //               builder: (BuildContext context) {
                        //                 return AlertDialog(
                        //                   title: Text("Edit Message"),
                        //                   content: TextFormField(
                        //                     controller: editController,
                        //                     decoration: InputDecoration(
                        //                       hintText: "Enter updated message",
                        //                     ),
                        //                   ),
                        //                   actions: [
                        //                     TextButton(
                        //                       onPressed: () {
                        //                         Navigator.of(context).pop();
                        //                       },
                        //                       child: Text("Cancel"),
                        //                     ),
                        //                     TextButton(
                        //                       onPressed: () async {
                        //                         final updatedMessage = editController.text.trim();
                        //                         if (updatedMessage.isNotEmpty) {
                        //                           await editMessage(messages[index].id, updatedMessage);
                        //                           Navigator.of(context).pop();
                        //                           // Navigator.of(context).pushNamed(ChatLayout());
                        //                           // Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatLayout(currentUser: CustomClass.currentUser, user: null, databaseRef: null,)));
                        //                         }
                        //                       },
                        //                       child: Text("Update"),
                        //                     ),
                        //                   ],
                        //                 );
                        //               },
                        //             );
                        //           },
                        //         ),
                        //         Divider(),
                        //         SimpleDialogOption(
                        //           child: Text("Delete"),
                        //           onPressed: () async {
                        //             await deleteMessage(messages[index].id);
                        //             Navigator.of(context).pop();
                        //           },
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // ),

                        onLongPress: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              children: [
                                SimpleDialogOption(
                                  child: Text("Copy"),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: messages[index]['message']),
                                    );
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Message copied to clipboard")),
                                    );
                                  },
                                ),
                                // Divider(),
                                // SimpleDialogOption(
                                //   child: Text("Reply"),
                                //   onPressed: () {
                                //     Navigator.of(context).pop();
                                //     setState(() {
                                //       message.text = "Replying to: ${messages[index]['message']}";
                                //     });
                                //   },
                                // ),
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
                                          // message: messages[index]['message'],
                                          // user: widget.user,
                                          // databaseRef: widget.databaseRef,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Divider(),
                                // SimpleDialogOption(
                                //   child: Text(messages[index]['starred'] == true ? "Unstar" : "Star"),
                                //   onPressed: () async {
                                //     await widget.databaseRef.collection("messages").doc(messages[index].id).update({
                                //       "starred": !(messages[index]['starred'] ?? false),
                                //     });
                                //     Navigator.of(context).pop();
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       SnackBar(
                                //         content: Text(
                                //           messages[index]['starred'] == true ? "Message unstarred" : "Message starred",
                                //         ),
                                //       ),
                                //     );
                                //   },
                                // ),
                                // Divider(),
                                // SimpleDialogOption(
                                //   child: Text(messages[index]['pinned'] == true ? "Unpin" : "Pin"),
                                //   onPressed: () async {
                                //     await widget.databaseRef.collection("messages").doc(messages[index].id).update({
                                //       "pinned": !(messages[index]['pinned'] ?? false),
                                //     });
                                //     Navigator.of(context).pop();
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       SnackBar(
                                //         content: Text(
                                //           messages[index]['pinned'] == true ? "Message unpinned" : "Message pinned",
                                //         ),
                                //       ),
                                //     );
                                //   },
                                // ),
                                Divider(),
                                SimpleDialogOption(
                                  child: Text("Edit"),
                                  onPressed: () async {
                                    final TextEditingController editController = TextEditingController(
                                      text: messages[index]['message'],
                                    );

                          return Column(
                            crossAxisAlignment:
                            x ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              ChatBubble(
                                clipper: ChatBubbleClipper1(
                                    type: x ? BubbleType.sendBubble : BubbleType.receiverBubble),
                                alignment: x ? Alignment.topRight : Alignment.topLeft,
                                margin: EdgeInsets.symmetric(
                                    horizontal: width * 0.012, vertical: height * 0.012),
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
                              ),
                              SizedBox(height: 4), // Small gap

                              /// ✅ **Checkmark for Sent & Seen Messages**
                              if (x) // Only show for sent messages
                                Padding(
                                  padding: EdgeInsets.only(right: width * 0.02),
                                  child: Icon(
                                    seenStatus ? Icons.done_all : Icons.check,
                                    size: 16,
                                    color: seenStatus ? Colors.green : Colors.grey,
                                  ),
                                ),
                            ],
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
                                    color: Color(0xFF995BF8),
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
