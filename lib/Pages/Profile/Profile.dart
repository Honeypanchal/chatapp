import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
class Profile extends StatefulWidget {
  final CustomClass currentUser;
  const Profile({super.key,required this.currentUser});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/chatPage',arguments: {'currentUser':widget.currentUser});
        break;
      case 1:
        Navigator.pushNamed(
          context,
          '/groupDisplay',
          arguments: {'currentUser': widget.currentUser},
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/statusPage');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile',arguments: {'currentUser':widget.currentUser});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
