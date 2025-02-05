import 'package:chatapp/Pages/statuspage.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/services/groupChat_services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Pages/Chat_layout/ChatPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDisplayPage.dart';
import 'package:chatapp/Pages/Profile/Profile.dart';

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
      GroupDisplayPage(),
      StatusPage(),
      Profile()
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, size: 26),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined, size: 26),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, size: 26),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 26),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        onTap: _onItemTapped,
      ),
    );
  }
}





/*
import 'package:chatapp/Pages/statuspage.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/services/groupChat_services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Pages/Chat_layout/ChatPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDisplayPage.dart';
import 'package:chatapp/Pages/Profile/Profile.dart';

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
      GroupDisplayPage(),
      StatusPage(),
      Profile()
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: Color(0xFF00A884),
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}


*/

/*
import 'package:chatapp/Pages/statuspage.dart';
import 'package:chatapp/models/CustomClass.dart';

import 'package:chatapp/services/groupChat_services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Pages/Chat_layout/ChatPage.dart';

import 'package:chatapp/Pages/GroupChatLayout/GroupDisplayPage.dart';
import 'package:chatapp/Pages/Profile/Profile.dart';

// import '../GroupChatLayout/GroupDisplayPage.dart';


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
      GroupDisplayPage(),

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
            border: Border.all(color: Colors.white)
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
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.person),
            //   label: 'Profile',
            // ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}


*/


/*
import 'package:chatapp/Pages/statuspage.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/services/groupChat_services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Pages/Chat_layout/ChatPage.dart';
// import 'package:chat_application/Pages/HomePage.dart';
// import 'package:chat_application/Pages/Profile.dart';

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
      // HomePage(currentUser: widget.currentUser),
      ChatPage(currentUser: widget.currentUser, ),
      StatusPage(),
      // ProfilePage(currentUser: widget.currentUser),
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
          border: Border.all(color: Colors.white)
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'chat',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
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
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
*/
