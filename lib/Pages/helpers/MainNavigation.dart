import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';


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
          color: Colors.white, // Set background color for the container
          border: Border.all(color: Colors.white),
        ),
        child: FlashyTabBar(
          backgroundColor: Colors.white,
          items: [
            FlashyTabBarItem(
              inactiveColor: Colors.grey,
              activeColor:Color.fromRGBO(21, 171, 97, 1),
              icon: Icon(Icons.chat_sharp),
              title: Text("Chats",style: TextStyle(fontWeight: FontWeight.bold)),
            ),
             FlashyTabBarItem(
               inactiveColor: Colors.grey,
               activeColor: Color.fromRGBO(21, 171, 97, 1),
              icon: Icon(Icons.groups_outlined),
              title: Text("Groups",style: TextStyle(fontWeight: FontWeight.bold),),
            ),
             FlashyTabBarItem(
               inactiveColor: Colors.grey,
               activeColor: Color.fromRGBO(21, 171, 97, 1),
              icon: Icon(Icons.camera),
              title: Text("Status",style: TextStyle(fontWeight: FontWeight.bold)),
            ),
             FlashyTabBarItem(
               inactiveColor: Colors.grey,
               activeColor:Color.fromRGBO(21, 171, 97, 1),
              icon: Icon(Icons.person),
              title: Text("Profile",style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],

            selectedIndex: currentIndex,

          onItemSelected: onTap,

        ));
  }
}
