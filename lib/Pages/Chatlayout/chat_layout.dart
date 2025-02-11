import 'package:chatapp/Pages/ChatLayout/ContectInfo.dart';
import 'package:chatapp/Pages/ChatLayout/UserInfoPage.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  bool _isLoading = false;
  List messages = [];
  ScrollController scrollController = ScrollController();
  Set<String> addedDates = {};
  late Stream<QuerySnapshot> messageStream;
  String? replyToMessage;
  String? replyToSender;
  bool isAppBarForSelectedMessages =
      false; // Check if the app bar should show options for selected messages
  List<String> selectedMessages = []; // To store selected message ids

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
  Future<void> favoriteMessages(id) async {
    for (var messageId in selectedMessages) {
      var message =
          messages.firstWhere((msg) => msg.id == messageId, orElse: () => null);
      if (message != null) {
        favoriteMessages(message
            .id); // Implement favoriteMessage functionality to update the star status in your database
      }
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

  /// Formats date to show "Today", "Yesterday" or a specific date
  String formatDateForGrouping(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(messageTime);
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
  // @override
  Widget build(BuildContext context) {
    final TextEditingController message = TextEditingController();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Group messages by date
    Map<String, List<DocumentSnapshot>> groupedMessages = {};
    for (var message in messages) {
      final messageDate = formatDateForGrouping(message['timestamp']);
      if (!groupedMessages.containsKey(messageDate)) {
        groupedMessages[messageDate] = [];
      }
      groupedMessages[messageDate]!.add(message);
    }

    // Flatten the grouped messages into a list with separators
    List<Widget> messageWidgets = [];
    groupedMessages.forEach((date, messages) {
      // Add date separator
      messageWidgets.add(
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      // Add messages for this date
      for (var message in messages) {
        final messageData = message.data() as Map<String, dynamic>;
        final isCurrentUser = messageData['sentBy'] == widget.currentUser.uid;
        final repliedMessage = messageData['replyTo'];
        final repliedSender = messageData['replyToSender'];
        final messageId = message.id;

        bool x = messageData['sentBy'] == widget.currentUser.uid;
        bool seenStatus =
            messageData.containsKey('seen') ? messageData['seen'] : false;
        bool isEdited =
            messageData.containsKey('edited') ? messageData['edited'] : false;

        messageWidgets.add(
          GestureDetector(
            onLongPress: () {
              toggleMessageSelection(messageId);
            },
            onHorizontalDragEnd: (details) {
              setState(() {
                replyToMessage = messageData['message'];
                replyToSender =
                    isCurrentUser ? "You" : widget.user['firstName'];
              });
            },
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (repliedMessage != null)
                  Container(
                    margin: EdgeInsets.only(
                      left: isCurrentUser
                          ? width > 600
                              ? width * 0.05
                              : width * 0.2
                          : width > 600
                              ? width * 0.01
                              : width * 0.04,
                      right: isCurrentUser
                          ? width > 600
                              ? width * 0.01
                              : width * 0.04
                          : width > 600
                              ? width * 0.05
                              : width * 0.2,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: selectedMessages.contains(messageId)
                      ? Colors.grey.shade300
                      : Colors.transparent,
                  child: Align(
                    alignment: isCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrentUser ? Color(0XFFD5FCD0) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            messageData['message'],
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  isCurrentUser ? Colors.black : Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.Hm().format(
                                  (messageData['timestamp'] as Timestamp)
                                      .toDate(),
                                ),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                seenStatus ? Icons.done_all : Icons.check,
                                size: 16,
                                color: seenStatus ? Colors.blue : Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1),
                if (x)
                  Padding(
                    padding: EdgeInsets.only(
                        right: width > 600 ? width * 0.01 : width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isEdited)
                          if (messageData['edited'] == true)
                            const Text(
                              "Edited",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Color(0XFFF6F1EB),
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.072),
        child: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: isAppBarForSelectedMessages
              ? Text(
                  "${selectedMessages.length} selected",
                  style: TextStyle(color: Colors.black),
                )
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
              IconButton(
                icon: const Icon(Icons.push_pin, color: Colors.black),
                onPressed: pinMessages,
              ),
              IconButton(
                icon: const Icon(Icons.star, color: Colors.black),
                onPressed: () {
                  for (var messageId in selectedMessages) {
                    var message = messages.firstWhere(
                        (msg) => msg.id == messageId,
                        orElse: () => null);
                    if (message != null) {
                      favoriteMessages(message.id);
                    }
                  }
                  setState(() {
                    selectedMessages.clear();
                    isAppBarForSelectedMessages = false;
                  });
                },
              ),
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: () {
                      int index = messages.indexWhere(
                          (message) => selectedMessages.contains(message.id));
                      if (index != -1) {
                        for (var messageId in selectedMessages) {
                          var message = messages.firstWhere(
                              (msg) => msg.id == messageId,
                              orElse: () => null);
                          if (message != null) {
                            deleteMessage(message.id);
                          }
                        }
                        setState(() {
                          selectedMessages.clear();
                          isAppBarForSelectedMessages = false;
                        });
                      }
                    },
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) {
                  int index = messages.indexWhere(
                      (message) => selectedMessages.contains(message.id));
                  String messageId = selectedMessages.first;
                  if (value == 'edit') {
                    final TextEditingController editController =
                        TextEditingController(text: messages[index]['message']);
                    if (selectedMessages.length == 1) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text("Edit Message"),
                            content: TextField(
                              controller: editController,
                              decoration: const InputDecoration(
                                  focusColor: Colors.green,
                                  border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.green)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.green)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.green)),
                                  labelText: "Message",labelStyle: TextStyle(color: Colors.black)),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.black),
                                ),
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
                                child: const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      setState(() {
                        selectedMessages.clear();
                        isAppBarForSelectedMessages = false;
                      });
                    } else {
                      final snackbar = SnackBar(
                          content: const Text('updated only on 1 message'));
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      setState(() {
                        selectedMessages.clear();
                        isAppBarForSelectedMessages = false;
                      });
                    }
                  } else if (value == 'copy') {
                    Clipboard.setData(
                      ClipboardData(
                          text: selectedMessages.map((messageId) {
                        var msgData =
                            messages.firstWhere((msg) => msg.id == messageId);
                        return msgData['message'];
                      }).join("\n")),
                    );
                    setState(() {
                      selectedMessages.clear();
                      isAppBarForSelectedMessages = false;
                    });
                  } else if (value == 'info') {
                    if (selectedMessages.length == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInfoPage(
                            messageData:
                                messages[index].data() as Map<String, dynamic>,
                            deliveredAt: messages[index]['deliveredAt'],
                            readAt: messages[index]['readAt'],
                          ),
                        ),
                      );
                    } else {
                      final snackbar = SnackBar(
                          content: const Text('Info only on 1 message'));
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      setState(() {
                        selectedMessages.clear();
                        isAppBarForSelectedMessages = false;
                      });
                    }
                  }
                },
                itemBuilder: (context) => [
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
                offset: Offset(30, 58),
              ),
            ],
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: messages.isNotEmpty
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount: messageWidgets.length,
                            itemBuilder: (context, index) {
                              return messageWidgets[index];
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.camera_alt, color: Colors.grey),
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
                            if (message.text.isNotEmpty) {
                              await sendMessage(message.text.trim());
                            } else {
                              final snackbar = SnackBar(
                                  content:
                                      const Text('Not send empty message'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackbar);
                              setState(() {
                                selectedMessages.clear();
                                isAppBarForSelectedMessages = false;
                              });
                            }
                            fetchMessagesByCurrentUser();
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
