
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDescription.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/users_services.dart';
import 'package:flutter/services.dart';

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

  void sendMessage({bool isPoll = false, List<
      String>? pollOptions, String? question}) async {
    String userId = _auth.currentUser!.uid;


    List<String> userNameList = await getUserNames([userId]);
    String username = userNameList.isNotEmpty ? userNameList.first : "Unknown";


    String? replyToMessageId = selectedReplyMessageId;
    String? replyToMessageText = selectedReplyMessageText;

    if (isPoll) {
      await _firestore.collection('groups')
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
        'status': 'sent',
      });

      setState(() {
        selectedReplyMessageId = null;
        selectedReplyMessageText = null;
      });
    } else if (_messageController.text
        .trim()
        .isNotEmpty) {
      await _firestore.collection('groups')
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
        'status': 'sent'
      });

      _messageController.clear();

      setState(() {
        selectedReplyMessageId = null;
        selectedReplyMessageText = null;
      });
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    DateTime messageDate = timestamp.toDate();
    DateTime now = DateTime.now();

    if (DateFormat('yyyy-MM-dd').format(messageDate) ==
        DateFormat('yyyy-MM-dd').format(now)) {
      return "Today";
    } else if (DateFormat('yyyy-MM-dd').format(messageDate) ==
        DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 1)))) {
      return "Yesterday";
    } else {
      return DateFormat('dd MMM yyyy').format(messageDate);
    }
  }

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }


//  Function to handle the reply
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

  void showMessageInfoDialog(BuildContext context, String messageId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.black, // Black background
      builder: (context) {
        return StreamBuilder<List<String>>(
          stream: getReadReceipts(messageId),
          builder: (context, readSnapshot) {
            return StreamBuilder<List<String>>(
              stream: getUnreadUsers(messageId),
              builder: (context, unreadSnapshot) {
                if (!readSnapshot.hasData || !unreadSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<String> readByUsers = readSnapshot.data ?? [];
                List<String> unreadByUsers = unreadSnapshot.data ?? [];

                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
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
                      Text(
                        "Read by:",
                        style: TextStyle(fontSize: 16,
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
                      Text(
                        "Not read by:",
                        style: TextStyle(fontSize: 16,
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
                          trailing: Icon(Icons.remove_red_eye_outlined,
                              color: Colors.grey),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void markMessageAsRead(String messageId) async {
    String userId = _auth.currentUser!.uid;

    DocumentReference messageRef = _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .doc(messageId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot messageSnapshot = await transaction.get(messageRef);
      List<dynamic> readByUsers = messageSnapshot['readBy'] ?? [];

      if (!readByUsers.contains(userId)) {
        transaction.update(messageRef, {
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
    });
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

      Map<String, dynamic> pollOptions = Map<String, dynamic>.from(
          pollDoc['pollOptions']);
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
      List<String> selectedVoters = List<String>.from(
          pollOptions[option] ?? []);
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
        selectedMessages.remove(
            messageId); // Deselect message if already selected
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
    getGroup();
  }

  StreamSubscription? _groupSubscription;

  void listenToDatabaseUpdates() {
    final groupRef = FirebaseFirestore.instance.collection("groups").doc(
        widget.groupId); // Corrected groupId reference

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
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => GroupDescription(
                    groupId: group['groupId'],
                    currentUser: widget.currentUser)));
          },
          child: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
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
                    String messageId = selectedMessages.first; // Using the first selected message as an example
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
                      showMessageInfoDialog(context, messageId); // Show info dialog
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
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                var messages = snapshot.data!.docs;

                Map<String, List<QueryDocumentSnapshot>> groupedMessages = {};
                for (var message in messages) {
                  String messageDate = formatDateForGrouping(message['timestamp']);
                  groupedMessages.putIfAbsent(messageDate, () => []).add(message);
                }

                // Sort the grouped dates so that 'Yesterday' appears above 'Today'
                List<String> sortedDates = groupedMessages.keys.toList()
                  ..sort((a, b) {
                    if (a == 'Today') return 1;
                    if (b == 'Today') return -1;
                    if (a == 'Yesterday') return -1;
                    if (b == 'Yesterday') return 1;
                    return DateFormat('MMM dd').parse(a).compareTo(DateFormat('MMM dd').parse(b));
                  });

                return ListView(
                  reverse: false, // Keeps the latest messages at the bottom
                  children: sortedDates.map((date) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...groupedMessages[date]!.map((message) {
                          bool isMe = message['senderUid'] == _auth.currentUser!.uid;
                          bool isPoll = message['isPoll'] ?? false;
                          bool isSelected = selectedMessages.contains(message.id);
                          bool isPinned = message['pinned'] ?? false;
                          bool isFavorite = message['favorite'] ?? false;
                          bool isSearched = searchQuery.isNotEmpty &&
                              RegExp(r'\b' + RegExp.escape(searchQuery) + r'\b', caseSensitive: false)
                                  .hasMatch(message['message']);

                          return GestureDetector(
                            onLongPress: () {
                              handleMessageLongPress(message.id);
                            },
                            child:Container(
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.grey[300] : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: isPinned ? Border.all(color: Colors.black, width: 2) : null,
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min, // Ensures the container adjusts based on content
                                children: [
                                  isPoll
                                      ? buildPollWidget(message, isMe)
                                      : IntrinsicWidth( // Use IntrinsicWidth here to adjust the container width
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isMe ? Colors.green.shade700 : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min, // Ensures the container adjusts to content
                                        children: [
                                          // Make sure to use Flexible for long messages
                                          Flexible(
                                            child: Text(
                                              message['message'],
                                              style: TextStyle(
                                                color: isMe ? Colors.white : Colors.black,
                                                backgroundColor: isSearched ? Colors.green : null,
                                              ),
                                              softWrap: true, // Allow text to wrap if too long
                                              maxLines: null, // Allow unlimited lines for long messages
                                              overflow: TextOverflow.visible, // Allow overflow to be visible
                                            ),
                                          ),
                                          if (isFavorite)
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              size: 18,
                                            ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              formatMessageTime(message['timestamp']),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isMe ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.012, vertical: height * 0.01),
            child: Row(
              children: [
                if (!group['sendMessages'] && !admins.contains(widget.currentUser)) ...[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Only Admins can send messages",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Raleway', color: Colors.black),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreatePollPage(
                                  sendMessage: sendMessage,
                                ),
                              ),
                            ),
                            child: Icon(Icons.poll, color: Colors.green.shade400),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: "Type a message",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: sendMessage,
                            child: Icon(Icons.send, color: Colors.green.shade400),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }



  String formatMessageTime(Timestamp timestamp) {
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  String formatDateForGrouping(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();

    if (messageTime.year == now.year && messageTime.month == now.month && messageTime.day == now.day) {
      return 'Today';
    } else if (messageTime.isBefore(now.subtract(Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(messageTime);
    }
  }

  //poll  display method
  Widget buildPollWidget(QueryDocumentSnapshot message, bool isSender) {
    Map<String, dynamic> pollOptions = Map<String, dynamic>.from(message['pollOptions'] ?? {});
    bool showVotes = false;
    Map<String, String> voterNames = {};

    return StatefulBuilder(
      builder: (context, setState) {
        Future<void> fetchVoterNames(List<dynamic> voterUids) async {
          List<String> fetchedNames = await getUserNames(voterUids.cast<String>());
          if (fetchedNames.isNotEmpty) {
            setState(() {
              for (int i = 0; i < voterUids.length; i++) {
                voterNames[voterUids[i]] = fetchedNames[i];
              }
            });
          }
        }

        return Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width * 0.75,
            decoration: BoxDecoration(
              color: isSender ? Colors.green.shade300 : Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),

                bottomLeft: isSender ? Radius.circular(12) : Radius.zero,
                bottomRight: isSender ? Radius.zero : Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['message'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSender ? Colors.white : Colors.black),
                ),
                SizedBox(height: 8),
                Column(
                  children: pollOptions.entries.map((entry) {
                    String option = entry.key;
                    List<dynamic> voters = entry.value ?? [];
                    int voteCount = voters.length;

                    fetchVoterNames(voters);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => votePoll(message.id, option),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 3),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(option, style: TextStyle(fontSize: 14, color: Colors.black)),
                                Text("$voteCount votes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                        if (showVotes && voters.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 10, top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: voters.map((uid) {
                                String voterName = voterNames[uid] ?? "Fetching...";
                                return Text("- $voterName", style: TextStyle(fontSize: 14, color: Colors.black87));
                              }).toList(),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 1),
                Divider(
                  thickness:1,
                  color:Colors.grey,
                ),
                Center(
                   child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showVotes = !showVotes;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          //color: isSender ? Colors.white : Colors.green.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            showVotes ? "Hide Votes" : "Show Votes",
                            style: TextStyle(
                              color: isSender ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )

                )
              ],
            ),
          ),
        );
      },
    );
  }


    Stream<List<String>> getReadReceipts(String messageId) {
    return _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .doc(messageId)
        .snapshots()
        .asyncMap((messageSnapshot) async {
      if (messageSnapshot.exists) {
        Map<String, dynamic>? data = messageSnapshot.data();
        List<dynamic> readBy = data?['readBy'] ?? [];
        return await getUserNames(List<String>.from(readBy)); // Await here
      }
      return [];
    });
  }

  Stream<List<String>> getUnreadUsers(String messageId) {
    return _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .doc(messageId)
        .snapshots()
        .asyncMap((messageSnapshot) async {
      if (messageSnapshot.exists) {
        Map<String, dynamic>? data = messageSnapshot.data();
        List<String> readBy = List<String>.from(data?['readBy'] ?? []);
        List<String> allMembers = List<String>.from(group['participants']);

        // Exclude read users and sender from unread list
        List<String> unreadUsers = allMembers.where((uid) => !readBy.contains(uid)).toList();
        unreadUsers.remove(messageSnapshot['senderUid']);

        return await getUserNames(unreadUsers); // Await here
      }
      return [];
    });
  }



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
class CreatePollPage extends StatefulWidget {
  final Function({
  bool isPoll,
  List<String>? pollOptions,
  String? question,
  }) sendMessage;

  CreatePollPage({required this.sendMessage});

  @override
  _CreatePollPageState createState() => _CreatePollPageState();
}

class _CreatePollPageState extends State<CreatePollPage> {
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController()
  ]; // Start with 2 options

  void createPoll() {
    List<String> pollOptions = optionControllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .map((controller) => controller.text.trim())
        .toList();

    if (questionController.text.trim().isNotEmpty && pollOptions.length >= 2) {
      widget.sendMessage(
        isPoll: true,
        pollOptions: pollOptions,
        question: questionController.text.trim(),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White theme background
      appBar: AppBar(
        title: Text(
          "Create a Poll",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: questionController,
              style: TextStyle(color: Colors.black, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Ask a question...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: optionControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: TextField(
                      controller: optionControllers[index],
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Option ${index + 1}",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        suffixIcon: index >= 2
                            ? IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red, size: 18),
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
                },
              ),
            ),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  if (optionControllers.length < 10) {
                    setState(() {
                      optionControllers.add(TextEditingController());
                    });
                  }
                },
                icon: Icon(Icons.add, color: Color(0xFF128C7E), size: 16),
                label: Text("Add Option",
                    style: TextStyle(color: Colors.green.shade400, fontSize: 15, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size(0, 0),
                ),
              ),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    backgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size(0, 0),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    backgroundColor: Colors.green.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size(0, 0),
                  ),
                  onPressed: createPoll,
                  child: Text("Create Poll", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



