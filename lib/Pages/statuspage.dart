import 'dart:convert';

import 'package:chatapp/services/status_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Status.dart';
import 'package:intl/intl.dart';

class StatusPage extends StatefulWidget {
  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  // String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //
  // int _selectedIndex=2;
  //
  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //
  //   switch (index) {
  //     case 0:
  //       Navigator.pushNamed(context, '/chatPage',
  //           arguments: {'currentUser': widget.currentUser});
  //       break;
  //     case 1:
  //       Navigator.pushNamed(
  //         context,
  //         '/groupDisplay',
  //         arguments: {'currentUser': widget.currentUser},
  //       );
  //       break;
  //     case 2:
  //       Navigator.pushNamed(context, '/statusPage');
  //       break;
  //     case 3:
  //       Navigator.pushNamed(context, '/profile',
  //           arguments: {'currentUser': widget.currentUser});
  //       break;
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height=MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Status',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: width * 0.06),
        ),
      ),
      body: Expanded(
        child:
        StreamBuilder<List<Status>>(
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
            //print("Statuses Fetched: ${snapshot.data!.length}");

            Map<String, List<Status>> notSeenStatuses = {};
            Map<String, List<Status>> seenStatuses = {};

            String currentUserId = FirebaseAuth.instance.currentUser!.uid;

            for (var status in snapshot.data!) {
              String username = status.username; // Grouping by username

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

            return ListView(
              children: [
                if (notSeenStatuses.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.015, left: width * 0.06),
                    child: Text(
                      "Recently Added",
                      style: TextStyle(
                        fontSize: width * 0.045, // Reduce font size a little
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  _buildStatusCategory("", notSeenStatuses, false),
                ] else
                  SizedBox.shrink(), // Prevent empty space when there are no unseen statuses

                if (seenStatuses.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.06, top: height * 0.015),
                    child: Text(
                      "Viewed Status",
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  _buildStatusCategory("", seenStatuses, true),
                ] else
                  SizedBox.shrink(), // Prevent empty space when there are no seen statuses
              ],
            );




          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EnterStatus()),
          );
        },
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(Icons.add, color: Colors.white,size: width*0.08,),
      ),
    );
  }

  Widget  _buildStatusCategory(
      String title, Map<String, List<Status>> groupedStatuses, bool isSeen) {
    if (groupedStatuses.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8,right: 8),
          child: Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: groupedStatuses.keys.length,
          itemBuilder: (context, index) {
            String userId = groupedStatuses.keys.elementAt(index);
            String username = groupedStatuses.keys.elementAt(index);
            List<Status> userStatus = groupedStatuses[username]!;

            return ListTile(
              leading: Container(
                decoration: BoxDecoration(

                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSeen ?
                        Colors.grey : Color(0XFF45C178),
                        width: 2)),
                child: CircleAvatar(
                  backgroundColor: Color(0XFFF3F9ED),
                  child: Text(userStatus[0].username[0].toUpperCase(),
                    style: TextStyle(color: Color(0XFF8BC34A)),),
                ),
              ),
              title: Text(username,style: TextStyle(fontFamily: 'poppins',fontWeight: FontWeight.w500),),
              subtitle: Text(isSeen?
              '${userStatus.length} status viewed ':'${userStatus.length}'
                  ' status available',style: TextStyle(
                  fontFamily: 'poppins',fontWeight: FontWeight.w600,color: Colors.grey),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewStatusScreen(statuses: userStatus),
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

  ViewStatusScreen({required this.statuses});

  @override
  State<ViewStatusScreen> createState() => _ViewStatusScreenState();
}

class _ViewStatusScreenState extends State<ViewStatusScreen> {
  final StatusService _statusService = StatusService();
  final TextEditingController _replyController = TextEditingController();

  void _showRepliesBottomSheet() {
    Status status = widget.statuses[currentIndex];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height*0.3,

          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "Status Replies",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              status.statusReplies.isEmpty
                  ? Center(child: Text("No replies available"))
                  : Expanded(
                child: ListView.builder(
                  itemCount: status.statusReplies.length,
                  itemBuilder: (context, index) {
                    final reply = status.statusReplies[index];

                    String replyBy = reply['replyBy'] ?? "Unknown";
                    String replyText = reply['replyText'] ?? "No reply";

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          replyBy[0].toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold),
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


  int currentIndex = 0;

  @override
  void initState() {

    super.initState();
    _markStatusAsViewed();
    _statusService.fetchAndPrintStatuses();
  }


  void _markStatusAsViewed() async {
    Status currentStatus = widget.statuses[currentIndex];
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    if (!currentStatus.viewedBy.contains(currentUserId)) {
      await _statusService.markStatusAsViewed(currentStatus.uid, currentUserId);

      setState(() {
        widget.statuses[currentIndex].viewedBy.add(currentUserId);
      });

      // Force StreamBuilder to refresh
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StatusPage()),
      );
    }
  }

  void _sendReply() async {
    String replyText = _replyController.text.trim();
    if (replyText.isEmpty) return;

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print(" Error: User is not authenticated.");
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
      setState(() {}); // Refresh UI
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
      child: Scaffold(
        backgroundColor: _hexToColor(status.backgroundColor),
        body: Column(
          children: [
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white,),

                      controller: _replyController,
                      decoration: InputDecoration(

                        prefixIcon: IconButton(onPressed: (){
                          _showRepliesBottomSheet();
                        },icon:  Icon(Icons.remove_red_eye,color: Colors.white,)),
                        fillColor: Colors.black26,
                        filled: true,
                        hintText: " Reply    ",
                        focusedBorder: InputBorder.none,

                        hintStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        suffixIcon: IconButton(onPressed: _sendReply, icon:Icon(Icons.send,color: Colors.white,),
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
    TextStyle(
        fontSize: 22,
        decoration: TextDecoration.underline,
        fontFamily: 'Rubik',
        color: Colors.white),
    TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        fontFamily: 'CedarvilleCursive',
        color: Colors.white),
  ];

  final List<Color> _backgroundColors = [
    Colors.red,
    Colors.blueAccent,
    Colors.pink,
    Colors.lightBlue.shade200,
    Colors.pinkAccent.shade100,
  ];
  final List<String> _colorHexCodes = [
    "#F44336",
    "2196F3",
    "#E91E63",
    "#81D4F3",
    "#F8BBD0"
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
                horizontal: width * 0.04,
                vertical: height * 0.025,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: height * 0.15,
                      width: width * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: width * 0.1,
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: _changeTextStyle,
                    child: Container(
                      height: height * 0.15,
                      width: width * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.text_fields_rounded,
                        color: Colors.white,
                        size: width * 0.1,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.01,
                  ),
                  GestureDetector(
                    onTap: _changeColor,
                    child: Container(
                      height: height * 0.15,
                      width: width * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.color_lens_sharp,
                        color: Colors.white,
                        size: width * 0.1,
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
          size: width * 0.07,
        ),
      ),
    );
  }
}