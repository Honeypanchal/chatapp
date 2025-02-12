import 'dart:async';
import 'dart:convert';

import 'package:chatapp/Pages/ChatLayout/ChatPage.dart';
import 'dart:io' as io;
import 'package:chatapp/Pages/GroupChatLayout/GroupDisplayPage.dart';
import 'package:chatapp/Pages/Profile/Profile.dart';
import 'package:chatapp/Pages/helpers/MainNavigation.dart';
import 'package:chatapp/services/status_service.dart';
import 'package:chatapp/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/CustomClass.dart';
import '../models/Status.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../services/auth_services.dart';
import 'package:flutter/foundation.dart';


class StatusPage extends StatefulWidget {
  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final StatusService _statusService = StatusService();
  final TextEditingController _statusController = TextEditingController();

  void _uploadTextStatus() {
    if (_statusController.text.trim().isNotEmpty) {
      String defaultColor = "#FFFFFF";
      _statusService.uploadStatus(
          _statusController.text.trim(), defaultColor, "0");
      _statusController.clear();
      Navigator.pop(context);
    }
  }

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late CustomClass currentUser;
  int _selectedIndex = 2;

  void fetchCurrentUser() async {
    final user = await getUserDetails(currentUserId);
    setState(() {
      currentUser = user!;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(currentUser: currentUser)));

          break;
        case 1:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      GroupDisplayPage(currentUser: currentUser)));
          break;
        case 2:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => StatusPage()));
          break;
        case 3:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Profile(currentUser: currentUser)

              ));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,

        title:Padding(padding:
        EdgeInsets.only(
            left: kIsWeb
                ? width * 0.001
                : width * 0.02,
            top: 2,
            bottom: 1),
          child:
          Text(
            'Status',
            style:

            TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width > 600
                  ? width * 0.02
                  : width * 0.06,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Status>>(
        stream: _statusService.getStatuses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No statuses available'),
            );
          }
          Map<String, List<Status>> notSeenStatuses = {};
          Map<String, List<Status>> seenStatuses = {};

          String currentUserId = FirebaseAuth.instance.currentUser!.uid;

          for (var status in snapshot.data!) {
            String username = status.username;
            if (status.viewedBy.contains(currentUserId)) {
              if (!seenStatuses.containsKey(username)) {
                seenStatuses[username] = [];
              }
              seenStatuses[username]!.add(status);
            } else {
              if (!notSeenStatuses.containsKey(username)) {
                notSeenStatuses[username] = [];
              }
              notSeenStatuses[username]!.add(status);
            }
          }

          if (notSeenStatuses.isEmpty && seenStatuses.isEmpty) {
            return Center(child: Text('No statuses available'));
          }

          return
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notSeenStatuses.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width > 600
                              ? width * 0.01
                              : width * 0.06,

                          top: 2,
                          bottom: 1
                      ),
                      child: Text(
                        "Recently Added",
                        style: TextStyle(
                          fontSize: width > 600 ? width * 0.01 : width * 0.05,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _buildStatusCategory("", notSeenStatuses, false),
                  ] else
                    SizedBox.shrink(),
                  if (seenStatuses.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width > 600
                              ? width * 0.01
                              : width * 0.06,
                          top: 2,
                          bottom: 1),
                      child: Text(
                        "Viewed Status",
                        style: TextStyle(
                          fontSize: width > 600 ? width * 0.01 : width * 0.05,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _buildStatusCategory("", seenStatuses, true),
                  ] else
                    SizedBox.shrink(),
                ],
              ),
            );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EnterStatus()),
          );
        },
        backgroundColor: Color.fromRGBO(21, 171, 97, 1),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: width > 600 ? width * 0.025 : width * 0.1,
        ),
      ),
      bottomNavigationBar: MainNavigationPage(
          currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }

  _buildStatusCategory(
      String title, Map<String, List<Status>> groupedStatuses, bool isSeen) {
    if (groupedStatuses.isEmpty) return SizedBox.shrink();
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8,bottom: 0,top: 0),
          child: Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ),
        ListView.builder(
          // padding: EdgeInsets.symmetric(vertical: 1),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: groupedStatuses.keys.length,
          itemBuilder: (context, index) {
            String userId = groupedStatuses.keys.elementAt(index);
            String username = groupedStatuses.keys.elementAt(index);
            List<Status> userStatus = groupedStatuses[username]!;



            bool isMyStatus = userStatus[0].userId == currentUserId;
            print("User ID from Status: ${userStatus[0].userId}, Current User ID: $currentUserId, isMyStatus: $isMyStatus");
            String displayName = isMyStatus ? "My Status" : userStatus[0].username;

            print("Final Display Name: $displayName");


            return ListTile(
              //minVerticalPadding: 10,
              //visualDensity: VisualDensity.compact,
              // visualDensity: VisualDensity(vertical: -4,horizontal: 0),
              //contentPadding: EdgeInsets.symmetric(horizontal: 0,vertical: 0),
              dense: true,
              // contentPadding: EdgeInsets.symmetric(vertical: 0),

              leading: Container(
                decoration: BoxDecoration(

                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSeen ? Colors.grey : Colors.green.shade600,
                        width: 2)),
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 232, 244, 234),
                  child: Text(
                    userStatus[0].username[0].toUpperCase(),
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
              ),
              title: Text(
                displayName,
                style: TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.w500
                ),
              ),
              subtitle: Text(
                isSeen
                    ? '${userStatus.length} status viewed '
                    : '${userStatus.length}'
                    ' status available',
                style: TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.grey),
              ),
              trailing: Text(
                DateFormat("HH:mm").format(userStatus.last.timestamp.toDate()),
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black54, // Adjust color if needed
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewStatusScreen(
                      statuses: userStatus,
                    ),
                  ),
                );
                setState(() {});
              },
            );
          },
        ),
      ],
    );
  }
}

class ViewStatusScreen extends StatefulWidget {
  final List<Status> statuses;

  //final bool isOwnStatus;

  ViewStatusScreen({required this.statuses});

  @override
  State<ViewStatusScreen> createState() => _ViewStatusScreenState();
}

class _ViewStatusScreenState extends State<ViewStatusScreen> {
  int currentIndex = 0;
  Timer? _viewTimer;
  String currentUserId="";

  @override
  void initState() {
    super.initState();
    _markStatusAsViewed();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _statusService.fetchAndPrintStatuses();
  }

  void _deleteStatus() async {
    for (var status in widget.statuses) {
      await _statusService.deleteStatus(status.uid);
    }
    Navigator.pop(context);
  }

  final StatusService _statusService = StatusService();
  final TextEditingController _replyController = TextEditingController();

  void _showRepliesBottomSheet() {
    Status status = widget.statuses[currentIndex];
    String currentUserId=FirebaseAuth.instance.currentUser!.uid;

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final width = MediaQuery.sizeOf(context).width;
        final height = MediaQuery.sizeOf(context).height;
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.3,
          padding: EdgeInsets.only(
            top: height * 0.03,
            left: MediaQuery.sizeOf(context).width > 600
                ? width * 0.02
                : width * 0.06,
            right: MediaQuery.sizeOf(context).width * 0.06,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status Replies",
                style: TextStyle(
                    fontSize: width > 600 ? width * 0.015 : width * 0.04,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
              status.statusReplies.isEmpty
                  ? Center(child: Text("No replies yet..."))
                  : Expanded(
                child: ListView.builder(
                  itemCount: status.statusReplies.length,
                  itemBuilder: (context, index) {
                    final reply = status.statusReplies[index];

                    String replyBy = reply['replyBy'] ?? "Unknown";
                    String replyText = reply['replyText'] ?? "No reply";

                    return
                      ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                        Color.fromARGB(255, 232, 244, 234),
                        child: Text(
                          replyBy[0].toUpperCase(),
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(
                        replyBy,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(replyText),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _markStatusAsViewed() {
    Status currentStatus = widget.statuses[currentIndex];
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    if (!currentStatus.viewedBy.contains(currentUserId)) {
      _viewTimer?.cancel();
      _viewTimer = Timer(Duration(seconds: 3), () async {
        await _statusService.markStatusAsViewed(
            currentStatus.uid, currentUserId);
        setState(() {
          widget.statuses[currentIndex].viewedBy.add(currentUserId);
        });

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StatusPage()),
        );
      });
    }
  }

  void _sendReply() async {
    String replyText = _replyController.text.trim();
    if (replyText.isEmpty) return;

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to reply.")),
      );
      return;
    }

    String statusId = widget.statuses[currentIndex].uid;
    String currentUserId = currentUser.uid;

    try {
      await _statusService.sendStatusReply(statusId, replyText);
      _replyController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" sent successfully!")),
      );
    } catch (e) {
      print("Error sending reply: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send reply. Try again.")),
      );
    }
  }

  void _nextStatus() {
    if (currentIndex < widget.statuses.length - 1) {
      setState(() {
        currentIndex++;
        _markStatusAsViewed();
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    Status status = widget.statuses[currentIndex];

    return GestureDetector(
      onTap: _nextStatus,
      onLongPress: () {
        _viewTimer?.cancel();
      },
      onLongPressUp: () {
        _markStatusAsViewed();
      },
      child: Scaffold(
        backgroundColor: _hexToColor(status.backgroundColor),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: width > 600 ? width * 0.015 : width * 0.06,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: width > 600 ? width * 0.003 : width * 0.01),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      radius: width > 600 ? width * 0.015 : width * 0.045,
                      child: Text(
                        widget.statuses[0].username[0].toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'poppins',
                            fontSize:
                            width > 600 ? width * 0.012 : width * 0.04),
                      ),
                    ),
                  ),
                  SizedBox(width: width > 600 ? width * 0.015 : width * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.statuses[0].username,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'poppins',
                              fontSize:
                              width > 600 ? width * 0.012 : width * 0.035,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          DateFormat("HH:mm")
                              .format(widget.statuses[0].timestamp.toDate()),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                            width > 600 ? width * 0.011 : width * 0.03,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  if (widget.statuses[currentIndex].userId ==
                      FirebaseAuth.instance.currentUser!.uid)
                    Container(
                      height: width > 600 ? height * 0.06 : height * 0.055,
                      width: width > 600 ? height * 0.06 : height * 0.055,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.black26),
                      child: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      content: Text(
                                        'Are you sure you want to delete status?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: width>600? width*0.017 : width*0.05),
                                      ),
                                      actions: [Column(
                                        children: [

                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'cancel',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                          TextButton(
                                              onPressed: () async {
                                                await _statusService.deleteStatus(
                                                    widget.statuses[currentIndex]
                                                        .uid);
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(color: Colors.red),
                                              ))
                                        ],)]
                                  );
                                });
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: width > 600 ? width * 0.015 : width * 0.05,
                          )),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    status.text,
                    style: _getTextStyle(status.textStyle),
                  ),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kIsWeb?25:10, vertical: kIsWeb?30:10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      controller: _replyController,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: kIsWeb? 10:2,right: kIsWeb?10:1),
                          child: IconButton(
                              onPressed: () {
                                _showRepliesBottomSheet();
                              },
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                              )),
                        ),
                        fillColor: Colors.black26,
                        filled: true,
                        hintText: " Reply",
                        focusedBorder: InputBorder.none,
                        hintStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: kIsWeb? 8:5),
                          child:
                          IconButton(
                            icon: Icon(Icons.send,color: Colors.white,),
                            onPressed:(){
                              if(widget.statuses[currentIndex].userId==currentUserId)
                              {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("you can't reply to your own status")
                                ));
                              }
                              else{
                                _sendReply();
                              }
                            }
                            
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getTextStyle(String styleIndex) {
    int index = int.tryParse(styleIndex) ?? 0;
    return _textStyles[index % _textStyles.length];
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      return Color(int.parse("0xFF$hexColor"));
    } else {
      return Colors.white;
    }
  }

  final List<TextStyle> _textStyles = [
    TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'Poppins'),
    TextStyle(
        fontSize: 22,
        fontStyle: FontStyle.italic,
        color: Colors.white,
        fontFamily: 'Raleway'),
  ];
}

class EnterStatus extends StatefulWidget {
  const EnterStatus({super.key});

  @override
  State<EnterStatus> createState() => _EnterStatusState();
}

class _EnterStatusState extends State<EnterStatus> {
  final StatusService _statusService = StatusService();
  final TextEditingController _statusController = TextEditingController();
  int _selectedStyleIndex = 0;
  int _colorIndex = 0;

  final List<TextStyle> _textStyles = [
    TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        color: Colors.white),
    TextStyle(
        fontSize: 22,
        fontStyle: FontStyle.italic,
        fontFamily: 'Raleway',
        color: Colors.white),
    TextStyle(fontSize: 22, fontFamily: 'Rubik', color: Colors.white),
    TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        fontFamily: 'CedarvilleCursive',
        color: Colors.white),
  ];

  final List<Color> _backgroundColors = [
    Colors.pinkAccent.shade100,
    Colors.green.shade200,
    Colors.orange.shade200,
    Colors.pink,
    Colors.lightBlue.shade200,

  ];
  final List<String> _colorHexCodes = [
    "#F8BBD0",
    "#A5D5A7",
    "#FFCC80",
    "#E91E63",
    "#81D4F3",

  ];

  void _changeColor() {
    setState(() {
      _colorIndex = (_colorIndex + 1) % _backgroundColors.length;
    });
  }

  void _changeTextStyle() {
    setState(() {
      _selectedStyleIndex = (_selectedStyleIndex + 1) % _textStyles.length;
    });
  }

  void _uploadTextStatus() {
    if (_statusController.text.trim().isNotEmpty) {
      String selectedColorHEX = _colorHexCodes[_colorIndex];
      String selectedStyleIndex = _selectedStyleIndex.toString();
      _statusService.uploadStatus(
          _statusController.text.trim(), selectedColorHEX, selectedStyleIndex);
      _statusController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: _backgroundColors[_colorIndex],
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width > 600 ? width * 0.02 : width * 0.06,
                vertical: height * 0.02,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: height * 0.15,
                      width: width > 600 ? width * 0.035 : width * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: width > 600 ? width * 0.02 : width * 0.07,
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: _changeTextStyle,
                    child: Container(
                      height: height * 0.15,
                      width: width > 600 ? width * 0.035 : width * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.text_fields_rounded,
                        color: Colors.white,
                        size: width > 600 ? width * 0.02 : width * 0.07,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.02,
                  ),
                  GestureDetector(
                    onTap: _changeColor,
                    child: Container(
                      height: height * 0.15,
                      width: width > 600 ? width * 0.035 : width * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.color_lens_sharp,
                        color: Colors.white,
                        size: width > 600 ? width * 0.02 : width * 0.07,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _statusController,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: _textStyles[_selectedStyleIndex],
                      decoration: InputDecoration(
                        hintText: 'Type a Status',
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadTextStatus,
        backgroundColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(
          Icons.send,
          color: Colors.white,
          size: width > 600 ? width * 0.015 : width * 0.066,
        ),
      ),
    );
  }
}