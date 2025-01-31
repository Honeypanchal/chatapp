import 'package:chatapp/Pages/GroupChatLayout/GroupPermissions.dart';
import 'package:chatapp/models/CustomClass.dart';
import 'package:chatapp/models/Group.dart';
import 'package:chatapp/services/users.dart';
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

  List<String> membersFirstNameList=[];
  Future<void> memebersFirstName() async {
    List<String> fetchedNames = await getUserNames(widget.members);
    setState(() {
      membersFirstNameList = fetchedNames;
    });
  }


  bool groupSettings=true;

  bool sendMessages=true;

  bool addOtherMembers=true;
  TextEditingController _groupName = TextEditingController();

  @override
  void initState(){
    super.initState();
    memebersFirstName();
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'New  Group',
          style: TextStyle(fontFamily: 'Raleway',color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: Colors.black, // WhatsApp color
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
                      backgroundColor: Colors.black12,
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
                          ),
                          Spacer(),
                        IconButton(onPressed: (){
                          print("Not implemented disappearing messages yet!");
                        }, icon:   Icon(
                          Icons.timer,
                          color: Colors.grey,
                          size: width * 0.06,
                        ))
                        ],
                      ),
                      Text(
                        'Off',
                        style: TextStyle(
                          fontSize: width * 0.03,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.014,
                      ),
                      Row(
                        children: [
                          Text(
                            'Group Permissions',
                            style: TextStyle(
                              fontSize: width * 0.042,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () async{
                               final result= await  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Grouppermissions(
                                      groupSettings: groupSettings,
                                      sendMessages: sendMessages,
                                      addOtherMembers: addOtherMembers,

                                    )));
                              if(result!=null){
                                groupSettings=result['groupSettings'];
                                sendMessages=result['sendMessages'];
                                addOtherMembers=result['addOtherMembers'];

                              }
                              },
                              icon: Icon(
                                Icons.settings,
                                color: Colors.grey,
                                size: width * 0.06,
                              ))
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
                  itemCount: membersFirstNameList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: width * 0.1,

                            child: Icon(Icons.person),
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            membersFirstNameList[index],
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
            try {

              Group? newGroup = await createNewGroup(
                _groupName.text.trim(),
                "assets/images/images.jpg",
                "Group Description",
                widget.createdBy.uid,
                widget.members,
                groupSettings,
                sendMessages,
                addOtherMembers


              );

              if (newGroup != null) {

                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => Groupchatpage(newGroup: newGroup))).
              catchError((error){
                  print(error.toString());
                });
                //Adding group id to user and participants
                widget.createdBy.addGroupAndAddActiveGroup(newGroup.groupId!);


                for (var singleMember in widget.members) {

                  addGroupAndAddActiveGroupInDatabase(newGroup.groupId!, singleMember);
                }

                print("Group created successfully: ${newGroup.groupId}");
                // widget.members.clear();
                _groupName.clear();
              } else {
                print("Group creation failed.");
              }
            } catch (e, stackTrace) {
              print("Unexpected error: $e");
              print("StackTrace: $stackTrace");
            }
          }
        },
        backgroundColor: Colors.black,
        child: Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }
}
