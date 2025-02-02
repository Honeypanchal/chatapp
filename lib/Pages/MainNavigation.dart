import 'package:chatapp/Pages/statuspage.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/services/groupChat_services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Pages/ChatPage.dart';
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
      Statuspage(),
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
