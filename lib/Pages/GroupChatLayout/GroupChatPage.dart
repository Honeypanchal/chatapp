// import 'package:chatapp/models/Group.dart';
// import 'package:flutter/material.dart';
import 'package:chatapp/Pages/ChatPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDescription.dart';
import 'package:chatapp/models/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Groupchatpage extends StatefulWidget {
  final Group newGroup;
  const Groupchatpage({super.key, required this.newGroup});

  @override
  State<Groupchatpage> createState() => _GroupchatpageState();
}

class _GroupchatpageState extends State<Groupchatpage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _firestore.collection('groups').doc(widget.newGroup.groupId).collection('messages').add({
        'sender': _auth.currentUser!.uid,
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height;
    final width=MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width, height*0.072)  ,child: GestureDetector(
          onTap: (){

Navigator.of(context).push(MaterialPageRoute(builder: (context)=>GroupChatDetails(groupId: widget.newGroup.groupId!)));
          },child: AppBar(

            leading: IconButton(onPressed: (){
Navigator.of(context).pop();
            }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
            title: Text(widget.newGroup.groupName,style: TextStyle(color: Colors.white),),
            actions: [
          Row(children: [
            IconButton(onPressed: (){}, icon: Icon(Icons.call,color: Colors.white,)),
             IconButton(onPressed: (){}, icon:      Icon(Icons.video_call,color: Colors.white,),)
          ],)

            ],
            backgroundColor: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.newGroup.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isMe = message['sender'] == _auth.currentUser!.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(

                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
               // Text(widget.newGroup.groupId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

