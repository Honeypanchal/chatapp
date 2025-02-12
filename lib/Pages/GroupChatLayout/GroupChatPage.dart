import 'dart:async';
import 'package:flutter/foundation.dart';
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
import 'GroupChatInfoPage.dart';

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
  bool isFetching = false; // To track function executio

  Future<void> membersFirstName() async {
    if (isFetching) return; // ✅ Prevent duplicate calls
    isFetching = true;

    try {
      print("Fetching participants...");

      if (group == null || !group.containsKey('participants')) {
        print("Group data is null or missing participants.");
        return;
      }

      List<String> newParticipants = (group['participants'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();

      // ✅ Sort lists before comparing
      newParticipants.sort();
      participants.sort();

      if (listEquals(participants, newParticipants)) {
        print("Participants unchanged, skipping fetch.");
        return;
      }

      participants = List.from(newParticipants);
      print("Participants changed, fetching names...");

      List<String> fetchedNames = await getUserNames(participants);

      if (mounted) {
        setState(() {
          membersFirstNameList = fetchedNames;
        });
      }
    } catch (e) {
      print("Error fetching member first names: $e");
    } finally {
      isFetching = false; // ✅ Reset flag after execution
    }
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
  String? selectedMessageId;

  Future<void> getGroupParticipants(String groupId) async {
    if (isFetching) return;
    isFetching = true;

    try {
      print("Fetching participants for group: $groupId");

      DocumentSnapshot groupSnapshot =
          await _firestore.collection('groups').doc(groupId).get();
      if (!groupSnapshot.exists) {
        print("⚠️ Group $groupId does not exist.");
        return;
      }

      Map<String, dynamic>? groupData =
          groupSnapshot.data() as Map<String, dynamic>?;
      if (groupData == null || !groupData.containsKey('participants')) {
        print("No participants found for group $groupId.");
        return;
      }

      List<String> newParticipants =
          List<String>.from(groupData['participants']);

      newParticipants.sort();
      participants.sort();

      if (listEquals(participants, newParticipants)) {
        print(" Participants unchanged, skipping fetch.");
        return;
      }

      participants = List.from(newParticipants);
      print("Participants updated: $participants");
    } catch (e) {
      print("Error fetching participants: $e");
    } finally {
      isFetching = false;
    }
  }

  void sendMessage(
      {bool isPoll = false,
      List<String>? pollOptions,
      String? question}) async {
    String userId = _auth.currentUser!.uid;
    List<String> userNameList = await getUserNames([userId]);
    String username = userNameList.isNotEmpty ? userNameList.first : "Unknown";
    String? replyToMessageId = selectedReplyMessageId;
    String? replyToMessageText = selectedReplyMessageText;
    await getGroupParticipants(group['groupId']);
    List<String> groupMembers = List.from(participants);
    if (selectedMessageId != null) {
      editMessage(selectedMessageId!, _messageController.text.trim());

      setState(() {
        selectedMessageId = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _messageController.clear();
      });

      return;
    }

    Map<String, dynamic> messageData = {
      'senderUid': userId,
      'sender': username,
      'timestamp': FieldValue.serverTimestamp(),
      'pinned': false,
      'favorite': false,
      'isPoll': isPoll,
      'isEdited': false,
      'replyToMessageId': replyToMessageId,
      'replyToMessageText': replyToMessageText,
      'status': 'sent',
      'deliveredTo': groupMembers, // ✅ Dynamically fetched participants
      'readBy': [userId] // Empty initially, updated when users see the message
    };

    if (isPoll) {
      messageData['message'] = question;
      messageData['pollOptions'] = {
        for (var option in pollOptions!) option: []
      };
    } else {
      messageData['message'] = _messageController.text.trim();
    }

    await _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .add(messageData);

    setState(() {
      selectedReplyMessageId = null;
      selectedReplyMessageText = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _messageController.clear();
    });
  }

  void markMessagesAsRead() async {
    String userId = _auth.currentUser!.uid;

    var messages = await _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .where("deliveredTo", arrayContains: userId)
        .get();

    for (var doc in messages.docs) {
      List<String> readBy = List<String>.from(doc["readBy"] ?? []);
      if (!readBy.contains(userId)) {
        // ✅ Prevents duplicate updates
        await _firestore
            .collection('groups')
            .doc(group['groupId'])
            .collection('messages')
            .doc(doc.id)
            .update({
          "readBy": FieldValue.arrayUnion([userId]),
          "deliveredTo": FieldValue.arrayRemove([userId]),
        });
      }
    }
  }

  FocusNode _messageFocusNode = FocusNode();

  void editMessage(String messageId, String newMessage) async {
    if (messageId.isEmpty || newMessage.trim().isEmpty)
      return; // Prevent empty edits

    await _firestore
        .collection('groups')
        .doc(group['groupId'])
        .collection('messages')
        .doc(messageId)
        .update({
      'message': newMessage.trim(),
      'isEdited': true,
      'editedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      selectedMessageId = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _messageController.clear();
    });

    if (mounted && !_messageFocusNode.hasFocus) {
      Future.microtask(() {
        _messageFocusNode.requestFocus();
      });
    }
  }

  void submitEditedMessage() {
    if (selectedMessageId != null &&
        _messageController.text.trim().isNotEmpty) {
      editMessage(selectedMessageId!, _messageController.text);
    }
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
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

  void startSearch() => setState(() => isSearching = true);

  void stopSearch() => setState(() => isSearching = false);

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
  late CustomClass user;

  late bool sendMessages;

  late bool addOtherMembers;

  void getCurrentUserDetails() async {
    CustomClass? found = await getUserDetails(widget.currentUser);
    if (found != null && mounted) {
      setState(() {
        user = found;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
    getGroup();
    membersFirstName();
    listenToDatabaseUpdates();
  }

  StreamSubscription? _groupSubscription;

  void listenToDatabaseUpdates() {
    final groupRef =
        FirebaseFirestore.instance.collection("groups").doc(widget.groupId);

    _groupSubscription = groupRef.snapshots().listen((snapshot) async {
      print("Listening to changes...");

      if (snapshot.exists && mounted) {
        var updatedGroupData = snapshot.data() as Map<String, dynamic>;
        List<String> newParticipants =
            (updatedGroupData['participants'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();

        // ✅ Sort lists before comparing
        newParticipants.sort();
        participants.sort();

        if (!listEquals(participants, newParticipants)) {
          print("Participants changed, fetching names...");
          participants = List.from(newParticipants);
          await membersFirstName();
        } else {
          print("Participants unchanged, skipping fetch.");
        }

        if (mounted) {
          setState(() {
            group = updatedGroupData;
            groupSettings = group['groupSettings'];
            sendMessages = group['sendMessages'];
            addOtherMembers = group['addOtherMembers'];
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _groupSubscription?.cancel(); //  Stop listening when widget is removed
    _groupSubscription = null; // Ensure it's set to null
    super.dispose();
  }

//change color theme
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF6F1EB),
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
                      arguments: {'currentUser': user});
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                )),
            title: selectedMessages.isNotEmpty
                ? Text("${selectedMessages.length} selected",
                    style: TextStyle(color: Colors.black))
                : isSearching
                    ? TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                            focusColor: Colors.green,
                            hintText: "Search messages",
                            hintStyle: TextStyle(color: Colors.black)),
                        onChanged: (query) =>
                            setState(() => searchQuery = query),
                      )
                    : Text(group['groupName'],
                        style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            actions: [
              if (selectedMessages.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.push_pin, color: Colors.black),
                  onPressed: pinMessages,
                ),
                IconButton(
                  icon: const Icon(Icons.star, color: Colors.black),
                  onPressed: favoriteMessages,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: deleteMessages,
                ),
                // Display 3 dots when messages are selected
                PopupMenuButton<String>(
                  color: Colors.white,
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (value) async {
                    String messageId = selectedMessages
                        .first; // Using the first selected message as an example
                    if (value == 'reply') {
                      // Perform reply action on selected message
                      String messageText = await getMessageTextById(messageId);
                      replyToMessage(messageText, messageId);
                    } else if (value == 'edit') {
                      String messageText = await getMessageTextById(messageId);

                      setState(() {
                        selectedMessageId =
                            messageId; // Store the message ID being edited
                        _messageController.text =
                            messageText; // Load message in input field
                      });
                    } else if (value == 'copy') {
                      copyMessage(messageId);
                    } else if (value == 'info') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MessageInfoPage(
                                messageId: messageId,
                                groupId: group['groupId'],
                                markMessagesAsRead: () =>
                                    markMessagesAsRead())),
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
              ] else ...[
                if (!isSearching)
                  IconButton(
                      icon: const Icon(Icons.search, color: Colors.black),
                      onPressed: startSearch),
                if (isSearching)
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
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
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                var messages = snapshot.data!.docs;

                Map<String, List<QueryDocumentSnapshot>> groupedMessages = {};

                for (var message in messages) {
                  Map<String, dynamic> messageData =
                      message.data() as Map<String, dynamic>;

                  Timestamp? timestamp = messageData['timestamp'] as Timestamp?;

                  String messageDate = timestamp != null
                      ? formatDateForGrouping(timestamp)
                      : ''; // Fallback value

                  groupedMessages
                      .putIfAbsent(messageDate, () => [])
                      .add(message);
                }

                List<String> sortedDates = groupedMessages.keys.toList()
                  ..sort((a, b) {
                    if (a == 'Today') return 1;
                    if (b == 'Today') return -1;
                    if (a == 'Yesterday') return -1;
                    if (b == 'Yesterday') return 1;

                    if (a.isEmpty || b.isEmpty) return 0;

                    try {
                      return DateFormat('MMM dd')
                          .parse(a)
                          .compareTo(DateFormat('MMM dd').parse(b));
                    } catch (e) {
                      return 0;
                    }
                  });

                return Column(
                  children: [
                    if (groupedMessages.values
                        .expand((messages) => messages)
                        .any((msg) => msg['pinned'] ?? false))
                      Builder(
                        builder: (context) {
                          var pinnedMessages = groupedMessages.values
                              .expand((messages) => messages)
                              .where((msg) => msg['pinned'] ?? false)
                              .toList();

                          var latestPinnedMessage = pinnedMessages.isNotEmpty
                              ? pinnedMessages.last
                              : null;

                          return latestPinnedMessage != null
                              ? Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.push_pin,
                                          color: Colors.black, size: 16),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          latestPinnedMessage['message'],
                                          style: TextStyle(color: Colors.black),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox.shrink();
                        },
                      ),

                    // Chat Messages Section
                    Expanded(
                      child: ListView(
                        reverse: false,
                        children: sortedDates.map((date) {
                          return Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                                bool isMe = message['senderUid'] ==
                                    _auth.currentUser!.uid;
                                bool isPoll = message['isPoll'] ?? false;
                                bool isSelected =
                                    selectedMessages.contains(message.id);
                                bool isPinned = message['pinned'] ?? false;
                                bool isFavorite = message['favorite'] ?? false;
                                bool isSearched = searchQuery.isNotEmpty &&
                                    RegExp(
                                            r'\b' +
                                                RegExp.escape(searchQuery) +
                                                r'\b',
                                            caseSensitive: false)
                                        .hasMatch(message['message']);

                                return Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onLongPress: () {
                                        handleMessageLongPress(message.id);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        margin:
                                            EdgeInsets.only(left: 5, right: 5),
                                        alignment: isMe
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.grey[300]
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            isPoll
                                                ? buildPollWidget(message, isMe)
                                                : IntrinsicWidth(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 12),
                                                      margin: EdgeInsets.only(
                                                          left: 5, right: 5),
                                                      decoration: BoxDecoration(
                                                        color: isMe
                                                            ? Color.fromARGB(
                                                                255,
                                                                213,
                                                                252,
                                                                208)
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Align(
                                                            alignment: isMe
                                                                ? Alignment
                                                                    .centerRight
                                                                : Alignment
                                                                    .centerLeft,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                // Sender name inside the message container (top left)
                                                                if (!isMe)
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            1),
                                                                    child: Text(
                                                                      (message.data() as Map<
                                                                              String,
                                                                              dynamic>)['sender'] ??
                                                                          'Unknown',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .grey[600],
                                                                      ),
                                                                    ),
                                                                  ),

                                                                if (isPinned)
                                                                  SizedBox(
                                                                      width: 5),
                                                                Flexible(
                                                                  child: Text(
                                                                    message[
                                                                        'message'],
                                                                    style:
                                                                        TextStyle(
                                                                      color: isMe
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .black,
                                                                      backgroundColor: isSearched
                                                                          ? Colors
                                                                              .green
                                                                          : null,
                                                                    ),
                                                                    softWrap:
                                                                        true,
                                                                    maxLines:
                                                                        null,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .visible,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              if (isPinned)
                                                                Icon(
                                                                    Icons
                                                                        .push_pin,
                                                                    color: Colors
                                                                        .black,
                                                                    size: 16),
                                                              if (isFavorite)
                                                                Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .yellow
                                                                      .shade500,
                                                                  size: 14,
                                                                ),
                                                              SizedBox(
                                                                  width: 4),
                                                              Align(
                                                                alignment: Alignment
                                                                    .bottomRight,
                                                                child: Text(
                                                                  formatMessageTime(
                                                                      message[
                                                                          'timestamp']),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: isMe
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ),
                                                              if (message[
                                                                      'isEdited'] ==
                                                                  true) // Display "Edited" if the message is modified
                                                                Text(
                                                                    '  (Edited)',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.012, vertical: height * 0.01),
            child: Row(
              children: [
                if (!group['sendMessages'] &&
                    !admins.contains(widget.currentUser)) ...[
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
                        style: TextStyle(
                            fontFamily: 'Raleway', color: Colors.black),
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
                        //border: Border.all(color: Colors.black, width: 1.5),
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
                            child: Icon(Icons.poll, color: Colors.grey[500]),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: "Type a message",
                                focusColor: Colors.green,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: sendMessage,
                            child: Icon(Icons.send, color: Colors.grey[500]),
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

  String formatMessageTime(Timestamp? timestamp) {
    try {
      if (timestamp == null) return 'Invalid Time'; // Handle null timestamps
      DateTime dateTime = timestamp.toDate();
      return DateFormat('HH:mm').format(dateTime); // 24-hour format
    } catch (e) {
      return 'Invalid Time'; // Fallback for error handling
    }
  }

  // String formatMessageTime(Timestamp? timestamp) {
  //   try {
  //     if (timestamp == null) return 'Invalid Time'; // Handle null timestamps
  //     return DateFormat('hh:mm a').format(timestamp.toDate());
  //   } catch (e) {
  //     return 'Invalid Time';  // Fallback for error handling
  //   }
  // }
  String formatDateForGrouping(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown'; // Ensure no empty values

    final now = DateTime.now();
    final messageTime = timestamp.toDate();

    if (messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day) {
      return 'Today';
    } else if (messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(messageTime);
    }
  }

  Widget buildSenderName(Map<String, dynamic>? message) {
    if (message == null || message['senderUid'] == _auth.currentUser?.uid) {
      return SizedBox.shrink(); // Don't show sender name for the current user
    }

    String senderName =
        message['sender']?.toString() ?? 'Unknown'; // Safely fetch sender name

    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 2),
      child: Text(
        senderName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  //poll  display method
  Widget buildPollWidget(QueryDocumentSnapshot message, bool isSender) {
    Map<String, dynamic> pollOptions =
        Map<String, dynamic>.from(message['pollOptions'] ?? {});
    ValueNotifier<bool> showVotes = ValueNotifier<bool>(false);
    Map<String, String> voterNames = {};

    List<dynamic> allVoters =
        pollOptions.values.expand((voters) => voters).toSet().toList();

    Future<void> fetchVoterNames(List<dynamic> voters) async {
      try {
        List<String> fetchedNames = await getUserNames(voters.cast<String>());
        for (int i = 0; i < voters.length; i++) {
          voterNames[voters[i]] = fetchedNames[i];
        }
      } catch (e) {
        print("Error fetching voter names: $e");
      }
    }

    return FutureBuilder(
      future: fetchVoterNames(allVoters),
      builder: (context, snapshot) {
        return Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400, // Limit width for web responsiveness
            ),
            margin: EdgeInsets.only(left: 5, right: 5),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color:
                  isSender ? Color.fromARGB(255, 213, 252, 208) : Colors.white,
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
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
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
                                Text(option,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                Text("$voteCount votes",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: showVotes,
                          builder: (context, value, child) {
                            return Column(
                              children: [
                                if (value && voters.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: 10, top: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: voters.map((uid) {
                                        String voterName =
                                            voterNames[uid] ?? "Fetching...";
                                        return Text("- $voterName",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black));
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 5),
                ValueListenableBuilder(
                  valueListenable: showVotes,
                  builder: (context, value, child) {
                    return TextButton(
                      onPressed: () {
                        showVotes.value = !showVotes.value;
                      },
                      child: Center(
                        child: Text(
                          value ? "Hide Voters" : "Show Voters",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  // Align timestamp to the bottom right
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, right: 5),
                    child: Text(
                      formatMessageTime(message['timestamp']),
                      // Display formatted time
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ),
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
        List<String> unreadUsers =
            allMembers.where((uid) => !readBy.contains(uid)).toList();
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
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
                focusColor: Colors.green,
                hintText: "Ask a question...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        focusColor: Colors.green,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        suffixIcon: index >= 2
                            ? IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.green.shade200, size: 18),
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
                icon: Icon(Icons.add, color: Colors.green, size: 16),
                label: Text("Add Option",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
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
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size(0, 0),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size(0, 0)),
                  onPressed: createPoll,
                  child: Text("Create Poll",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
