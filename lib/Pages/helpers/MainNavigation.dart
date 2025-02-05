import 'package:flutter/material.dart';
import 'package:chatapp/Pages/ChatPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDisplayPage.dart';
import 'package:chatapp/Pages/Profile/Profile.dart';
import 'package:chatapp/Pages/statuspage.dart';

class MainNavigationPage extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
 const  MainNavigationPage({
    required this.currentIndex,
    required this.onTap,});
  @override
  Widget build(BuildContext context) {
    return Container(
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
          currentIndex: currentIndex,
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.white,
          onTap: onTap,
          type: BottomNavigationBarType.fixed, // Ensures full background color
        ));
  }
}
