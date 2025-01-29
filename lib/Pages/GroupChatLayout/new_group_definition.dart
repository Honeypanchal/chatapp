import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/models/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/groupChat.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupChatPage.dart';

class NewGroupDefinition extends StatefulWidget {
  final List<String> members;
  final CustomClass createdBy;

  const NewGroupDefinition(
      {super.key, required this.members, required this.createdBy});

  @override
  State<NewGroupDefinition> createState() => _NewGroupDefinitionState();
}

class _NewGroupDefinitionState extends State<NewGroupDefinition> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    TextEditingController _groupName = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'New  Group',
          style: TextStyle(fontFamily: 'Raleway'),
        ),
        backgroundColor: Colors.blue[600], // WhatsApp color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.032, vertical: height * 0.032),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Name Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CircleAvatar(
                      radius: width * 0.066,
                      backgroundColor: Colors.blue.shade300,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.012,
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _groupName,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.0), // Color when focused
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.0), // Color when not focused
                          ),
                          hintText: 'Group Name'),
                      style: TextStyle(
                        fontSize: width * 0.05,
                        fontFamily: 'Raleway',
                        color: Colors.black,
                      ),
                      validator: (val) {
                        if (val!.isEmpty)
                          return 'Enter Group Name';
                        else
                          return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),
              Divider(
                height: height * 0.012,
                color: Colors.grey.shade100,
                thickness: width * 0.02,
              ),
              SizedBox(
                height: height * 0.012,
              ),
              // Permissions Section
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.032, vertical: height * 0.012),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Disappearing messages ',
                            style: TextStyle(
                              fontSize: width * 0.042,

                              color: Colors.black87,
                            ),
                          ),Spacer(),
                          Opacity(
                              opacity: 0.8,
                              child: Icon(
                                Icons.timer,
                                color: Colors.grey,
                              size: width*0.06,))
                        ],
                      ),
                      Opacity(
                        opacity: 0.9,
                        child: Text(
                          'Off',
                          style: TextStyle(
                            fontSize: width * 0.03,

                            color: Colors.black87,
                          ),
                        ),
                      ),SizedBox(height: height*0.014,),
                      Row(
                        children: [
                          Text(
                            'Group Permissions',
                            style: TextStyle(
                              fontSize: width * 0.042,

                              color: Colors.black87,
                            ),
                          ),Spacer(),
                          Opacity(
                              opacity: 0.9,
                              child: Icon(
                                Icons.settings,
                                color: Colors.grey,
                                size: width*0.06,))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Divider(
                height: height * 0.01,
                color: Colors.grey.shade100,
                thickness: width * 0.005,
              ),
              // Member Count Section
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.032, vertical: height * 0.012),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Members : ${widget.members.length}',
                      style: TextStyle(
                        fontSize: width * 0.035,

                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              // Member Profiles Section
              Container(
                height: height * 0.3, // Adjusted height for members list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.members.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: width * 0.1,
                            // Adjusted size for avatars
                            child: Icon(Icons.person),
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            widget.members[index],
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_groupName.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Enter Group Name",
                style: TextStyle(fontFamily: 'Raleway', color: Colors.white),
              ),
              backgroundColor: Colors.red.shade300,
            ));
          } else {
            Group newGroup = await createNewGroup(
                _groupName.text.trim().toString(),
                "assets/images/jpg",
                "groupDescription",
                widget.createdBy.uid,
                widget.members,
                Timestamp.now());
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Groupchatpage(newGroup: newGroup)));
          }
        },
        backgroundColor: Colors.blue[600],
        child: Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }
}
