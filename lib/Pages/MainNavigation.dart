import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Pages/ChatPage.dart';
// import 'package:chat_application/Pages/HomePage.dart';
// import 'package:chat_application/Pages/Profile.dart';

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
      ChatPage(currentUser: widget.currentUser),
      // ProfilePage(currentUser: widget.currentUser),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white)
        ),
        child: BottomNavigationBar(
          backgroundColor: Color(0xFF242935),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF995BF8),
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
