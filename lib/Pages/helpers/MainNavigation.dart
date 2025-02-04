import 'package:chatapp/Pages/statuspage.dart';
import 'package:chatapp/models/CustomClass.dart';


import 'package:flutter/material.dart';
import 'package:chatapp/Pages/ChatPage.dart';

import 'package:chatapp/Pages/GroupChatLayout/GroupDisplayPage.dart';
import 'package:chatapp/Pages/Profile/Profile.dart';


// file is updated1
class MainNavigationPage extends StatefulWidget {
  final CustomClass currentUser;

  MainNavigationPage({required this.currentUser});

  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      ChatPage(currentUser: widget.currentUser),
     GroupDisplayPage(currentUser:widget.currentUser.uid),

      StatusPage(),
      Profile()
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
    decoration: BoxDecoration(
    color: Colors.black, // Set background color for the container
      border: Border.all(color: Colors.white),
    ),
    child: BottomNavigationBar(
    backgroundColor: Colors.black,
    items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
    icon: Icon(Icons.chat_sharp),
    label: 'Chats',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.groups_outlined),
    label: 'Groups',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.camera),
    label: 'Status',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.person),
    label: 'Profile',
    ),
    ],
    currentIndex: _selectedIndex,
    selectedItemColor: Colors.green.shade400,
    unselectedItemColor: Colors.white,
    onTap: _onItemTapped,
    type: BottomNavigationBarType.fixed, // Ensures full background color
    )
    ,
    )
    ,

    );
  }
}
