import 'dart:async';
import 'package:intl/intl.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDescription.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/users_services.dart';
import 'package:flutter/services.dart';

import '../../models/CustomClass.dart';
import '../../services/auth_services.dart';
import '../../services/groupChat_services.dart';

class Groupchatpage extends StatefulWidget {
  final String groupId;
  final String currentUser;

  const Groupchatpage({
    Key? key,
    required this.groupId,
    required this.currentUser,
  }) : super(key: key);

  @override
  _GroupchatpageState createState() => _GroupchatpageState();
}

class _GroupchatpageState extends State<Groupchatpage> {
  dynamic group;
  List<String> admins = [];
  late CustomClass user;

  void getCurrentUserDetails() async {
    CustomClass? found = await getUserDetails(widget.currentUser);
    if (found != null) {
      setState(() {
        user = found;
      });
    }
  }

  Future<void> getGroup() async {
    try {
      final anothergroup = await fetchGroupByGroupId(widget.groupId!);
      setState(() {
        group = anothergroup;
        print(group['groupId']);
      });

      if (group != null) {
        setState(() {
          admins = (group['admins'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          groupSettings = group['groupSettings'];
          sendMessages = group['sendMessages'];
          addOtherMembers = group['addOtherMembers'];
        });
        listenToDatabaseUpdates();
        await membersFirstName();
      }
    } catch (e) {
      print('Error fetching group details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> participants = [];
  List<String> membersFirstNameList = [];

  Future<void> membersFirstName() async {
    print(group['participants']);

    setState(() {
      participants = (group['participants'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      print(participants[0]);
    });

    List<String> fetchedNames = await getUserNames(participants);

    setState(() {
      membersFirstNameList = fetchedNames;
    });
  }

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
  String? selectedReplyMessageId;
  String? selectedReplyMessageText;

  void sendMessage(
      {bool isPoll = false,
      List<String>? pollOptions,
      String? question}) async {
    String userId = _auth.currentUser!.uid;

    // Fetch sender's username
    List<String> userNameList = await getUserNames([userId]);
    String username = userNameList.isNotEmpty ? userNameList.first : "Unknown";

    // Check if replying to a message
    String? replyToMessageId = selectedReplyMessageId;
    String? replyToMessageText = selectedReplyMessageText;

    if (isPoll) {
      await _firestore
          .collection('groups')
          .doc(group['groupId'])
          .collection('messages')
          .add({
        'senderUid': userId,
        'sender': username,
        // Store username instead of UID
        'message': question,
        // Poll question
        'timestamp': FieldValue.serverTimestamp(),
        'isPoll': true,
        'pinned': false,
        'favorite': false,
        'pollOptions': {for (var option in pollOptions!) option: []},
        // Ensure options start empty
        'replyToMessageId': replyToMessageId,
        // Store replied message ID
        'replyToMessageText': replyToMessageText,
        // Store replied message text
      });

      setState(() {
        selectedReplyMessageId = null;
        selectedReplyMessageText = null;
      });
    } else if (_messageController.text.trim().isNotEmpty) {
      await _firestore
          .collection('groups')
          .doc(group['groupId'])
          .collection('messages')
          .add({
        'senderUid': userId,
        'sender': username, // Store username instead of UID
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'pinned': false,
        'favorite': false,
        'isPoll': false,
        'replyToMessageId': replyToMessageId, // Store replied message ID
        'replyToMessageText': replyToMessageText, // Store replied message text
      });

      _messageController.clear();

      setState(() {
        selectedReplyMessageId = null;
        selectedReplyMessageText = null;
      });
    }
  }

  void showCreatePollDialog(BuildContext context) {
    TextEditingController questionController = TextEditingController();
    List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController()
    ]; // Start with 2 options

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Create a Poll",
            style: TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: questionController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ask a question...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children:
                          List.generate(optionControllers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: TextField(
                            controller: optionControllers[index],
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Option ${index + 1}",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: UnderlineInputBorder(),
                              suffixIcon: index >= 2
                                  ? IconButton(
                                      icon: Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          optionControllers.removeAt(index);
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          if (optionControllers.length < 10) {
                            setState(() {
                              optionControllers.add(TextEditingController());
                            });
                          }
                        },
                        child: Text(
                          "+ Add Option",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                List<String> pollOptions = optionControllers
                    .where((controller) => controller.text.trim().isNotEmpty)
                    .map((controller) => controller.text.trim())
                    .toList();

                if (questionController.text.trim().isNotEmpty &&
                    pollOptions.length >= 2) {
                  sendMessage(
                    isPoll: true,
                    pollOptions: pollOptions,
                    question: questionController.text.trim(),
                  );

                  // Close the dialog
                  Navigator.pop(context);
                }
              },
              child: Text("Create Poll"),
            ),
          ],
        );
      },
    );
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
      _messageController.text =
          message; // Set message text to the input field for editing
      selectedMessages.clear(); // Clear any selected messages
    });
  }

  void showMessageInfoDialog(BuildContext context, String messageId) async {
    // Fetch the message data
    DocumentSnapshot messageSnapshot = await _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .doc(messageId)
        .get();

    String senderId = messageSnapshot['senderUid']; // Get the sender's ID

    // Get the list of users who read the message
    List<String> readByUsers =
        await getReadReceipts(messageId); // Users who read
    List<String> unreadByUsers =
        await getUnreadUsers(readByUsers); // Users who haven't read

    // Exclude the sender from unreadByUsers
    unreadByUsers.remove(senderId); // Remove sender from unread users list

    // Show the modal dialog with message info
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.black, // Black background
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black, // Set background to black
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button (X) to dismiss dialog
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                ),
              ),
              // Header
              Text(
                "Message Info",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey),
              // Read by users
              Text(
                "Read by:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 5),
              for (var user in readByUsers)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      user.isNotEmpty ? user[0].toUpperCase() : '',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  title: Text(
                    user,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(Icons.done_all, color: Colors.blue),
                ),
              Divider(color: Colors.grey),
              // Not read by users
              Text(
                "Not read by:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 5),
              for (var user in unreadByUsers)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      user.isNotEmpty ? user[0].toUpperCase() : '',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  title: Text(
                    user,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing:
                      Icon(Icons.remove_red_eye_outlined, color: Colors.grey),
                ),
            ],
          ),
        );
      },
    );
  }

  void markMessageAsRead(String messageId) async {
    String userId = _auth.currentUser!.uid;

    // Get the reference to the message document
    DocumentReference messageRef = _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .doc(messageId);

    // Get the current message data
    DocumentSnapshot messageSnapshot = await messageRef.get();

    // Check if the user has already read the message
    List<dynamic> readByUsers = messageSnapshot['readBy'] ?? [];

    if (!readByUsers.contains(userId)) {
      // If the user hasn't read it, update the readBy field
      await messageRef.update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void votePoll(String pollId, String option) async {
    DocumentReference pollRef = _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .doc(pollId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot pollDoc = await transaction.get(pollRef);
      if (!pollDoc.exists) return;

      Map<String, dynamic> pollOptions =
          Map<String, dynamic>.from(pollDoc['pollOptions']);
      String userId = _auth.currentUser!.uid;

      // Remove vote from other options
      pollOptions.forEach((key, value) {
        List<String> voters = List<String>.from(value ?? []);
        if (voters.contains(userId)) {
          voters.remove(userId);
          pollOptions[key] = voters;
        }
      });

      // Add vote to the selected option
      List<String> selectedVoters =
          List<String>.from(pollOptions[option] ?? []);
      if (!selectedVoters.contains(userId)) {
        selectedVoters.add(userId);
        pollOptions[option] = selectedVoters;
      }

      transaction.update(pollRef, {'pollOptions': pollOptions});
    });
  }

  // Function to start the search
  void startSearch() => setState(() => isSearching = true);

  // Function to stop the search
  void stopSearch() => setState(() => isSearching = false);

  // Function to handle the action of pinning messages
  void pinMessages() {
    selectedMessages.forEach((messageId) async {
      var docRef = _firestore
          .collection('groups')
          .doc(group['groupId'])
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
      var docRef = _firestore
          .collection('groups')
          .doc(group['groupId'])
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
      await _firestore
          .collection('groups')
          .doc(group['groupId'])
          .collection('messages')
          .doc(messageId)
          .delete();
    });
    setState(() {
      selectedMessages.clear(); // Clear selected messages after deleting
    });
  }

  // Function to handle the action of copying messages
  void copyMessage(String messageId) async {
    String messageText = await getMessageTextById(messageId);
    Clipboard.setData(ClipboardData(text: messageText));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Message copied to clipboard'),
    ));
    setState(() {
      selectedMessages.clear(); // Clear selected messages after copying
    });
  }

  void handleMessageLongPress(String messageId) {
    setState(() {
      if (selectedMessages.contains(messageId)) {
        selectedMessages
            .remove(messageId); // Deselect message if already selected
      } else {
        selectedMessages.add(messageId); // Select message if not selected
      }
    });
  }

//Listening to real time changes
  bool isLoading = true;
  late bool groupSettings;

  late bool sendMessages;

  late bool addOtherMembers;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
    getGroup();
  }

  StreamSubscription? _groupSubscription;

  void listenToDatabaseUpdates() {
    final groupRef = FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupId); // Corrected groupId reference

    _groupSubscription = groupRef.snapshots().listen((snapshot) async {
      print("Listening to changes...");

      if (snapshot.exists && mounted) {
        var updatedGroupData = snapshot.data() as Map<String, dynamic>;

        if (mounted) {
          setState(() {
            group = updatedGroupData;
            groupSettings = group['groupSettings'];
            sendMessages = group['sendMessages'];
            addOtherMembers = group['addOtherMembers'];
            isLoading = false; // Stop loading
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _groupSubscription?.cancel(); // Stop listening when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.072),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              '/groupDescription',
              arguments: {
                'groupId': group['groupId'],
                'currentUser': widget.currentUser,
              },
            );
          },
          child: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/groupDisplay',
                      arguments: {'currentUser':user});
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            title: selectedMessages.isNotEmpty
                ? Text("${selectedMessages.length} selected",
                    style: TextStyle(color: Colors.white))
                : isSearching
                    ? TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                            hintText: "Search messages",
                            hintStyle: TextStyle(color: Colors.white)),
                        onChanged: (query) =>
                            setState(() => searchQuery = query),
                      )
                    : Text(group['groupName'],
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
                  onSelected: (value) async {
                    String messageId = selectedMessages
                        .first; // Using the first selected message as an example
                    if (value == 'reply') {
                      // Perform reply action on selected message
                      String messageText = await getMessageTextById(messageId);
                      replyToMessage(messageText, messageId);
                    } else if (value == 'edit') {
                      // Perform edit action on selected message
                      String messageText = await getMessageTextById(messageId);
                      editMessage(messageText, messageId);
                    } else if (value == 'copy') {
                      // Perform copy action on selected message
                      copyMessage(messageId);
                    } else if (value == 'info') {
                      showMessageInfoDialog(
                          context, messageId); // Show info dialog
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
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('groups')
                  .doc(group['groupId'])
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    // Separate pinned and non-pinned messages
                    List pinnedMessages = messages
                        .where((msg) => msg['pinned'] ?? false)
                        .toList();
                    List unpinnedMessages = messages
                        .where((msg) => !(msg['pinned'] ?? false))
                        .toList();

                    // Combine pinned messages first, followed by unpinned messages
                    List allMessages = [...pinnedMessages, ...unpinnedMessages];

                    // Get the message for the current index
                    var message = allMessages[index];
                    bool isMe = message['senderUid'] == _auth.currentUser!.uid;
                    bool isPoll = message['isPoll'] ??
                        false; // Check if message is a poll
                    bool isSelected = selectedMessages.contains(message.id);
                    bool isPinned = message['pinned'] ??
                        false; // Check if message is pinned
                    bool isFavorite = message['favorite'] ??
                        false; // Check if message is favorite
                    bool isSearched = searchQuery.isNotEmpty &&
                        RegExp(r'\b' + RegExp.escape(searchQuery) + r'\b',
                                caseSensitive: false)
                            .hasMatch(message['message']);
                    bool isSelected1 = selectedMessages
                        .contains(message.id); // Check if message is selected

                    // Handle long press for selecting the message
                    return GestureDetector(
                      onLongPress: () {
                        handleMessageLongPress(message.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.grey[300]
                              : Colors.transparent, // Light grey if selected
                          borderRadius: BorderRadius.circular(10),
                          border: isPinned
                              ? Border.all(color: Colors.yellow, width: 2)
                              : null, // Border for pinned messages
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // Display pinned indicator for pinned messages at the top
                            if (isPinned)
                              Container(
                                color: Colors.grey[300],
                                // Grey background for pinned messages
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.push_pin,
                                        color: Colors.yellow, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      message['message'],
                                      style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            // Non-pinned message content
                            if (!isPinned)
                              isPoll
                                  ? buildPollWidget(
                                      message) // Display poll if it's a poll message
                                  : Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Colors.black
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            message['message'],
                                            style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                          // Favorite icon for favorited messages
                                          if (isFavorite)
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              size: 18,
                                            ),
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

          //NEHA YAHA SE MENE PERMISSIONS WALA KAAM KIYA HAI!!
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.012, vertical: height * 0.01),
            child: Row(children: [
              if (!participants.contains(widget.currentUser)) ...[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: width * 0.072, vertical: height * 0.012),
                    padding: EdgeInsets.all(width * 0.012),
                    width: width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      // WhatsApp-like green shade

                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "You are no longer a participant of this group",
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                )
              ] else ...[
                if (!group['sendMessages'] &&
                    !admins.contains(widget.currentUser)) ...[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: width * 0.035, vertical: height * 0.012),
                      padding: EdgeInsets.all(width * 0.012),
                      width: width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        // WhatsApp-like green shade

                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Only Admins can send messages",
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(Icons.poll, color: Colors.black),
                    onPressed: () => showCreatePollDialog(context),
                  ),
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
                ]
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget buildPollWidget(QueryDocumentSnapshot message) {
    Map<String, dynamic> pollOptions =
        Map<String, dynamic>.from(message['pollOptions'] ?? {});
    bool showVotes = false; // Toggle for showing votes
    Map<String, String> voterNames = {}; // Store voter UID -> Name mapping

    return StatefulBuilder(
      builder: (context, setState) {
        Future<void> fetchVoterNames(List<dynamic> voterUids) async {
          List<String> fetchedNames =
              await getUserNames(voterUids.cast<String>());
          if (fetchedNames.isNotEmpty) {
            setState(() {
              for (int i = 0; i < voterUids.length; i++) {
                voterNames[voterUids[i]] = fetchedNames[i];
              }
            });
          }
        }

        return Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message['message'], // Poll question
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: pollOptions.entries.map((entry) {
                  String option = entry.key;
                  List<dynamic> voters = entry.value ?? [];
                  int voteCount = voters.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => votePoll(message.id, option),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(option, style: TextStyle(fontSize: 14)),
                              Text("$voteCount votes",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      if (showVotes &&
                          voters
                              .isNotEmpty) // Fetch & show voter names dynamically
                        FutureBuilder(
                          future: fetchVoterNames(voters),
                          builder: (context, snapshot) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: voters.map((uid) {
                                  String voterName =
                                      voterNames[uid] ?? "Fetching...";
                                  return Text("- $voterName",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700]));
                                }).toList(),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showVotes = !showVotes; // Toggle votes display
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: showVotes ? Colors.black : Colors.black,
                    // Button background color
                    foregroundColor: Colors.white), // Text color
                child: Text(showVotes ? "Hide Votes" : "Show Votes"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>> getReadReceipts(String messageId) async {
    DocumentSnapshot messageSnapshot = await _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .doc(messageId)
        .get();

    if (messageSnapshot.exists) {
      Map<String, dynamic>? data =
          messageSnapshot.data() as Map<String, dynamic>?;
      List<dynamic> readBy = data?['readBy'] ?? [];

      // Fetch usernames from UIDs
      return getUserNames(List<String>.from(readBy));
    }
    return [];
  }

  Future<List<String>> getUnreadUsers(List<String> readByUsers) async {
    List<String> allMembers = List<String>.from(group['participants']);
    List<String> unreadUsers =
        allMembers.where((uid) => !readByUsers.contains(uid)).toList();

    // Fetch usernames from UIDs
    return getUserNames(unreadUsers);
  }

  // Function to retrieve message text by message ID
  Future<String> getMessageTextById(String messageId) async {
    DocumentSnapshot messageDoc = await _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .doc(messageId)
        .get();

    return messageDoc['message'] ?? ''; // Return the actual message content
  }
}
