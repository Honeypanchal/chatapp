import 'package:chatapp/models/Group.dart';
import 'package:flutter/material.dart';

import 'package:chatapp/services/users.dart';

class GroupChatDetails extends StatefulWidget {
  final dynamic group;

  const GroupChatDetails({super.key, required this.group});

  @override
  State<GroupChatDetails> createState() => _GroupChatDetailsState();
}

class _GroupChatDetailsState extends State<GroupChatDetails> {
  String firstName='';
 
  List<String> membersFirstNameList=[];
  Future<void> memebersFirstName() async {
    List<String> fetchedNames = await getUserNames(widget.group.participants);
    setState(() {
      membersFirstNameList = fetchedNames;
    });
  }

  Future<void> getDataAndUpdateUI() async {
    String enteredFirstName = await getFirstNameById(widget.group.createdBy); // Await the Future to get the value

    setState(() {
      firstName=enteredFirstName;
    });
  }
  @override
  void initState() {
    super.initState();

getDataAndUpdateUI();
    memebersFirstName();

  }

  void _showGroupDescriptionModal() {
    TextEditingController descriptionController = TextEditingController();

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;

        return Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          height: screenHeight * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Group Description",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,

                ),
              ),
              SizedBox(height: screenHeight * 0.015),


              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  focusColor: Colors.black,

                  hintText: "Add group description",
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),


              Text(
                "The group description is visible to members of this group and people invited to this group.",
                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
              ),
              Spacer(),


              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // No rounded corners
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      ),
                      onPressed: () {
                        String enteredDescription = descriptionController.text;
                        if(descriptionController.text.isEmpty){

                        }else{

                          print("Group Description: $enteredDescription");
                          Navigator.pop(context);
                        }
                      },
                      child: Text("OK", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: width * 0.13,
                backgroundColor: Colors.black,
                child:
                    Icon(Icons.group, color: Colors.white, size: width * 0.09),
              ),
            ),
            SizedBox(height: height * 0.012),
            Text(widget.group.groupName,
                style: TextStyle(fontSize: width * 0.055)),
            Text('Group · ${widget.group.participants.length} members',
                style: TextStyle(color: Colors.grey, fontSize: width * 0.042)),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(Icons.call, 'Audio'),
                _buildButton(Icons.videocam, 'Video'),
                _buildButton(Icons.person_add, 'Add'),
                _buildButton(Icons.search, 'Search'),
              ],
            ),
            SizedBox(height: height * 0.012),
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            SizedBox(height: height * 0.012),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.047, vertical: height * 0.017),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(onTap:(){
                    _showGroupDescriptionModal();
                  },
                    child: Text(
                      'Add group description',
                      style: TextStyle(
                          color: Colors.blue[500], fontSize: width * 0.037),
                    ),
                  ),
                  SizedBox(height: height * 0.005),

                    Text(
                        'Created by ${firstName}, ${(widget.group.createdAt)}',
                        style: TextStyle(color: Colors.grey, fontSize: 14),


                  ),
                ],
              ),
            ),
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            ListTile(
              leading: Icon(
                Icons.notifications_none,
                size: width * 0.06,
              ),
              title: Text(
                'Notifications',
                style: TextStyle(fontSize: width * 0.045),
              ),
              trailing: Icon(
                Icons.chevron_right,
                size: width * 0.07,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.image_outlined,
                size: width * 0.06,
              ),
              title: Text('Media visibility',
                  style: TextStyle(fontSize: width * 0.045)),
              trailing: Icon(
                Icons.chevron_right,
                size: width * 0.07,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.star_border,
                size: width * 0.06,
              ),
              title: Text('Starred messages',
                  style: TextStyle(fontSize: width * 0.045)),
              trailing: Text(''),
            ),
            SizedBox(height: height * 0.012),
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            SizedBox(height: height * 0.012),
            ListTile(
              leading: Icon(
                Icons.lock_outline,
                size: width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.012),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encryption',
                      style: TextStyle(fontSize: width * 0.045),
                    ),
                    Container(
                        width: width * 0.6,
                        child: Text(
                            "Messages and calls are end-to-end encrypted.",
                            style: TextStyle(
                                fontSize: width * 0.035, color: Colors.grey)))
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.timer_outlined,
                size: width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.012),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disappearing messages',
                        style: TextStyle(fontSize: width * 0.045)),
                    Text("off",
                        style: TextStyle(
                            fontSize: width * 0.035, color: Colors.grey))
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.mail_lock_outlined,
                size: width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.012),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chat lock',
                        style: TextStyle(fontSize: width * 0.045)),
                    Text("Lock and hide this chat on this device",
                        style: TextStyle(
                            fontSize: width * 0.035, color: Colors.grey))
                  ],
                ),
              ),
              trailing: Transform.scale(
                  scale: width * 0.002,
                  child: Switch(
                    value: false,
                    onChanged: (val) {},
                    activeColor: Colors.black,
                  )),
            ),
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            SizedBox(height: height * 0.012),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: width * 0.035, vertical: height * 0.012),
              padding: EdgeInsets.symmetric(horizontal: width * 0.012),
              child: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.group.participants.length} members ",
                        style: TextStyle(fontSize: width * 0.042),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(right: width*0.052),
                        child: Icon(
                          Icons.search,
                          size: width * 0.062,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: height*0.012,),

                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [    ListTile( contentPadding: EdgeInsets.zero,
                        leading:   CircleAvatar(
                            backgroundColor: Colors.black,
                            child:Icon(Icons.group_add_outlined,color: Colors.white,size: width*0.052,)
                        ),
                        title: Text("Add members",style: TextStyle(fontSize: width * 0.045),),
                      ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.group.participants.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.black,
                                child: Text(
                                  '${membersFirstNameList[index][0].toUpperCase()}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(membersFirstNameList[index]),
                              trailing: membersFirstNameList[index]==firstName?Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade200,borderRadius: BorderRadius.circular(width*0.01)
                                ),width: width*0.12,height: height*0.017,
                               child: Center(child: Text("Admin",style: TextStyle(fontSize: width*0.027,color: Colors.white),),),
                              ):null,

                            );
                          },
                        ),
                      ],
                    ),
                  )
,
                ],
              ),
            ),
            Divider(
                height: height * 0.012,
                thickness: height * 0.007,
                color: Colors.grey.shade100),
            SizedBox(height: height * 0.012),
            ListTile(
              leading: Icon(
                Icons.favorite_outline,
                size: width * 0.06,
              ),
              title: Text(
                'Add to Favourites',
                style: TextStyle(fontSize: width * 0.045),
              ),

            ),
            ListTile(
              leading: Icon(
                Icons.people_outline,
                size: width * 0.06,
              ),
              title: Text('Add to list',
                  style: TextStyle(fontSize: width * 0.045)),

            ),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                size: width * 0.06,color: Colors.red,
              ),
              title: Text('Exit group',
                  style: TextStyle(color: Colors.red,fontSize: width * 0.045)),

            ),
            ListTile(
              leading: Icon(
                Icons.thumb_down_alt_outlined,
                size: width * 0.06,color: Colors.red,
              ),
              title: Text('Report group',
                  style: TextStyle(color: Colors.red,fontSize: width * 0.045)),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.042, vertical: height * 0.017),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(width * 0.032),
          ),
          child: Icon(icon, color: Colors.black),
        ),
        SizedBox(height: height * 0.01),
        Text(label),
      ],
    );
  }
}
