import 'package:chatapp/Pages/GroupChatLayout/new_group_definition.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/Pages/chat_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final CustomClass currentUser;

  ChatPage({required this.currentUser});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _database = FirebaseFirestore.instance.collection('Users');
  dynamic chatsDB = FirebaseFirestore.instance.collection("chats");
  TextEditingController _searchText = new TextEditingController();
  dynamic _Chatdatabase = '';
  bool isMakingGroupChat=false;
  List _chatUsers = [];
  List<dynamic> groupChatUsers=[];

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() async {
    if(_searchText.text.isNotEmpty){
      final users = await _database
          .where("firstName",isEqualTo: _searchText.text.trim().toString())
          .get();
      return users.docs;
    }else
      {
        final users = await _database.get();
        return users.docs;
      }

  }

  @override
  void initState() {
    super.initState();
    _searchText.addListener((){
      fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchText.removeListener(() {});
    _searchText.dispose(); // Don't forget to dispose of the controller
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF242935),
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: width * 0.064),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              height: width > 600 ? width * 0.1 : width * 0.045,
              width: width > 600 ? width * 0.1 : width * 0.035,
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: width * 0.019),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: width > 600 ? width * 0.6 : width * 0.044,
                  ),
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFF242935),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMakingGroupChat?
             'New Group': 'Chats',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: width > 600 ? width * 0.05 : width * 0.052,
              ),
            ),

            if(isMakingGroupChat)
              Text(
               "Add members",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',

                  fontSize: width > 600 ? width * 0.04 : width * 0.032,
                ),
              )
          ],
        ),

      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;

          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: isWeb ? width * 0.1 : width * 0.012,
              vertical: height * 0.012,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if(isMakingGroupChat)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: height*0.012,horizontal: width*0.012),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: groupChatUsers.map((x) {
                        return CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF995BF8),
                          ),
                        );
                      }).toList(),
                    ),
                  )
,
                Container(
                  height: height * 0.052,
                  width: isWeb ? width * 0.8 : width * 0.9,
                  decoration: BoxDecoration(
                      color: Color(0xFF2C313F),
                      borderRadius: BorderRadius.circular(width * 0.09),
                      border: Border.all(color: Colors.white, width: 0.2)),
                  child: TextField(
                    controller: _searchText,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Raleway',
                    ),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Raleway',
                      ),
                      hintText: 'Search',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.025),

                // FutureBuilder to fetch users
                FutureBuilder<
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                  future: fetchUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No users found"));
                    }

                    _chatUsers = snapshot.data!;

                    return Expanded(
                      child: ListView.builder(

                        shrinkWrap: true,
                        itemCount: _chatUsers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onLongPress: (){
                              if(isMakingGroupChat)
                                {
                                 setState(() {
                                   groupChatUsers.add(_chatUsers[index]);
                                 });

                                }
                            },
                            onTap: () {
                              String docId = widget.currentUser.uid
                                          .compareTo(_chatUsers[index]['uid']) <
                                      0
                                  ? "${widget.currentUser.uid}_${_chatUsers[index]['uid']}"
                                  : "${_chatUsers[index]['uid']}_${widget.currentUser.uid}";
                              _Chatdatabase = chatsDB.doc(docId);

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatLayout(
                                  currentUser: widget.currentUser,
                                  user: _chatUsers[index],
                                  databaseRef: _Chatdatabase,
                                ),
                              ));
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF995BF8),
                              ),
                            ),
                            title: Text(
                              "${_chatUsers[index]['firstName']}  ${_chatUsers[index]['lastName']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {
          if(isMakingGroupChat && groupChatUsers.isNotEmpty){
print(groupChatUsers.length);
Navigator.of(context).push(MaterialPageRoute(builder: (context)=>NewGroupDefinition(members: groupChatUsers)));

            isMakingGroupChat=!isMakingGroupChat;
           setState(() {
             groupChatUsers.clear();
           });
          }else
            {
              setState(() {
                isMakingGroupChat=!isMakingGroupChat;
              });
            }

        },
        backgroundColor: Color(0xFF25D366),
        tooltip: 'Create New Group',
        child: Icon(
          isMakingGroupChat?Icons.arrow_forward:Icons.group_add,
          color: Colors.white,
          size: width < 600 ? width * 0.08 : width * 0.09,
        ), // Tooltip for the button
      ),
    );
  }
}
