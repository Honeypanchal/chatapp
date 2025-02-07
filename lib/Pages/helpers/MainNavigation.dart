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
          color: Colors.black, // Set background color for the container
          border: Border.all(color: Colors.white),
        ),
        child: FlashyTabBar(
          backgroundColor: Colors.black,
          items: [
            FlashyTabBarItem(
              inactiveColor: Colors.grey,
              activeColor: Colors.white,
              icon: Icon(Icons.chat_sharp),
              title: Text("Chats",style: TextStyle(color: Colors.white)),
            ),
             FlashyTabBarItem(
               inactiveColor: Colors.grey,
               activeColor: Colors.white,
              icon: Icon(Icons.groups_outlined),
              title: Text("Groups",style: TextStyle(color: Colors.white)),
            ),
             FlashyTabBarItem(
               inactiveColor: Colors.grey,
               activeColor: Colors.white,
              icon: Icon(Icons.camera),
              title: Text("Status",style: TextStyle(color: Colors.white)),
            ),
             FlashyTabBarItem(
               activeColor: Colors.white,
              inactiveColor: Colors.grey,
              icon: Icon(Icons.person),
              title: Text("Profile",style: TextStyle(color: Colors.white),),
            ),
          ],

            selectedIndex: currentIndex,

          onItemSelected: onTap,

        ));
  }
}
