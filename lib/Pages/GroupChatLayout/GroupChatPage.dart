import 'package:chatapp/models/Group.dart';
import 'package:flutter/material.dart';
class Groupchatpage extends StatefulWidget {
  final Group newGroup;
  const Groupchatpage({super.key,required this.newGroup});

  @override
  State<Groupchatpage> createState() => _GroupchatpageState();
}

class _GroupchatpageState extends State<Groupchatpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
body: Container(
  child: Text(widget.newGroup.groupId!),
),
    );
  }
}
