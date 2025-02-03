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
  final StatusService _statusService = StatusService();
  final TextEditingController _statusController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Status>>(
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

                for (var status in snapshot.data!) {
                  if (status.viewedBy.contains(currentUserId)) {
                    if (!seenStatuses.containsKey(status.uid)) {
                      seenStatuses[status.uid] = [];
                    }
                    seenStatuses[status.uid]!.add(status);
                  } else {
                    if (!notSeenStatuses.containsKey(status.uid)) {
                      notSeenStatuses[status.uid] = [];
                    }
                    notSeenStatuses[status.uid]!.add(status);
                  }
                }

                return ListView(
                  children: [
                    _buildStatusCategory(
                        "Recently Added (Not Seen)", notSeenStatuses),
                    _buildStatusCategory("Viewed Status", seenStatuses),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EnterStatus()),
          );
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusCategory(
      String title, Map<String, List<Status>> groupedStatuses) {
    if (groupedStatuses.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: groupedStatuses.keys.length,
          itemBuilder: (context, index) {
            String userId = groupedStatuses.keys.elementAt(index);
            List<Status> userStatus = groupedStatuses[userId]!;

            return ListTile(
              leading: CircleAvatar(
                child: Text(userStatus[0].username[0].toUpperCase()),
              ),
              title: Text(userStatus[0].username),
              subtitle: Text('${userStatus.length} status available'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewStatusScreen(statuses: userStatus),
                  ),
                );
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

  int currentIndex = 0;

  @override
  void _sendReply() {
    if (_replyController.text.trim().isNotEmpty) {
      String replyText = _replyController.text.trim();
      String statusText = widget.statuses[currentIndex].text;
      String receiverId =
          widget.statuses[currentIndex].uid; // Status owner's ID

      // Send reply to the chat of the status owner
      _statusService.sendStatusReply(receiverId, statusText, replyText);

      _replyController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Reply sent!")));
    }
  }

  void initState() {
    super.initState();
    _markStatusAsViewed();
  }

  void _markStatusAsViewed() {
    _statusService.markStatusAsViewed(widget.statuses[currentIndex].uid);
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
                      controller: _replyController,
                      decoration: InputDecoration(
                        fillColor: Colors.black26,
                        filled: true,
                        focusedBorder: InputBorder.none,
                        prefixIcon: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              builder: (BuildContext context) {
                                return Container(
                                  padding: EdgeInsets.all(16),
                                  height: 300, // Adjust height based on content
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Status Replies",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Divider(),
                                      Expanded(
                                        child: status.statusReply == null || status.statusReply.isEmpty
                                            ? Center(child: Text("No Replies Available"))
                                            : ListView.builder(
                                          shrinkWrap: true, // Ensures correct height
                                          itemCount: status.statusReply.length,
                                          itemBuilder: (context, index) {
                                            final reply = status.statusReply[index];

                                            return ListTile(
                                              leading: CircleAvatar(child: Icon(Icons.person)),
                                              title: Text(reply ['replyBy']?.toString() ?? "Unknown"),
                                              subtitle: Text(reply['replyText']?.toString() ?? ""),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.remove_red_eye,
                            color: Colors.white54,
                          ),
                        ),




                        hintText: "Reply",
                        hintStyle: TextStyle(
                            color: Colors.white54, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.04,
                  ),
                  Container(
                    height: height * 0.08,
                    width: width * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                    ),
                    child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_replyController.text.trim().isNotEmpty) {
                            _statusService.sendStatusReply(
                                widget.statuses[currentIndex].uid,
                                widget.statuses[currentIndex].uid,
                                _replyController.text.trim());
                            _replyController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Reply sent!")));
                          }
                        }),
                  ),
                ],
              ),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: status.statusReply.length ?? 0,
            //     itemBuilder: (context, index) {
            //       final reply = status.statusReply[index];
            //       return ListTile(
            //         leading: CircleAvatar(child: Icon(Icons.person)),
            //         title: Text(reply['replyBy'] ?? "Unknown"),
            //         // Fetch senderId
            //         subtitle:
            //             Text(reply['replyText'] ?? ""), // Fetch reply text
            //       );
            //     },
            //   ),
            // ),
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
