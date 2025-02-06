import 'package:flutter/material.dart';

class GroupDisplayPage extends StatefulWidget {
  const GroupDisplayPage({super.key});

  @override
  State<GroupDisplayPage> createState() => _GroupDisplayPageState();
}

class _GroupDisplayPageState extends State<GroupDisplayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('data',style: TextStyle(fontSize: 30),),),
    );
  }
}
