/*
import 'package:flutter/material.dart';

class ContectInfo extends StatelessWidget {
  const ContectInfo({super.key, required currentUser});

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
          onPressed: () {},
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
                child: Icon(Icons.group, color: Colors.white, size: width * 0.09),
              ),
            ),
            SizedBox(height: height * 0.012),
            Text("Group Name", style: TextStyle(fontSize: width * 0.055)),
            Text("Group · 10 members",
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
            Divider(color: Colors.grey.shade100, thickness: height * 0.007),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.047, vertical: height * 0.017),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Group Description",
                    style: TextStyle(color: Colors.blue[500], fontSize: width * 0.037),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    'Created by User, Date',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade100, thickness: height * 0.007),
            ListTile(
              leading: Icon(Icons.settings, size: width * 0.06),
              title: Text('Group permissions', style: TextStyle(fontSize: width * 0.045)),
            ),
            Divider(color: Colors.grey.shade100, thickness: height * 0.007),
            ListTile(
              leading: Icon(Icons.favorite_outline, size: width * 0.06),
              title: Text('Add to Favourites', style: TextStyle(fontSize: width * 0.045)),
            ),
            ListTile(
              leading: Icon(Icons.people_outline, size: width * 0.06),
              title: Text('Add to list', style: TextStyle(fontSize: width * 0.045)),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, size: width * 0.06, color: Colors.red),
              title: Text('Exit group', style: TextStyle(color: Colors.red, fontSize: width * 0.045)),
            ),
            ListTile(
              leading: Icon(Icons.thumb_down_alt_outlined, size: width * 0.06, color: Colors.red),
              title: Text('Report group', style: TextStyle(color: Colors.red, fontSize: width * 0.045)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.black),
        ),
        SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}

*/


import 'package:chatapp/services/users_services.dart';
import 'package:flutter/material.dart';
class ContectInfo extends StatelessWidget {
  final String currentUser;
  final String email;

  const ContectInfo({super.key,required this.currentUser, required this.email});

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
          onPressed: () {},
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
                backgroundColor: Colors.green[700],
                child: Text(currentUser[0].toUpperCase(),style: TextStyle(fontFamily: 'Poppins',fontSize: 38,color: Colors.white),),
              ),
            ),
            SizedBox(height: height * 0.012),
            Text(currentUser, style: TextStyle(fontSize: width * 0.055)),
            Text(email, style: TextStyle(color: Colors.grey, fontSize: width * 0.042)),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(Icons.call, 'Audio',context),
                _buildButton(Icons.videocam, 'Video',context),
                _buildButton(Icons.currency_rupee_outlined,'Pay',context),
                _buildButton(Icons.search, 'Search',context),
              ],
            ),
            SizedBox(height: height * 0.012),
            Divider(color: Colors.grey.shade100, thickness: height * 0.007),
            ListTile(
              leading: Icon(Icons.notifications_none, size: width * 0.06,),
              title: Text('Notifications', style: TextStyle(fontSize: width * 0.045),),
              trailing: Icon(Icons.chevron_right, size: width * 0.07,),
            ),
            ListTile(
              leading: Icon(Icons.image_outlined, size: width * 0.06),
              title: Text('Media visibility', style: TextStyle(fontSize: width * 0.045)),
              trailing: Icon(Icons.chevron_right, size: width * 0.07,),
            ),
            ListTile(
              leading: Icon(Icons.star_border, size: width * 0.06),
              title: Text('Starred messages', style: TextStyle(fontSize: width * 0.045)),
              trailing: Icon(Icons.chevron_right, size: width * 0.07,),
            ),
            Divider(color: Colors.grey.shade100, thickness: height * 0.007),
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
            Divider(color: Colors.grey.shade100, thickness: height * 0.007),
            ListTile(
              leading: Icon(Icons.favorite_outline, size: width * 0.06),
              title: Text('Add to Favourites', style: TextStyle(fontSize: width * 0.045)),
            ),
            ListTile(
              leading: Icon(Icons.people_outline, size: width * 0.06),
              title: Text('Add to list', style: TextStyle(fontSize: width * 0.045)),
            ),
            ListTile(
              leading: Icon(Icons.block_flipped, size: width * 0.06, color: Colors.red),
              title: Text('Block ${currentUser}', style: TextStyle(color: Colors.red, fontSize: width * 0.045)),
            ),
            ListTile(
              leading: Icon(Icons.thumb_down_alt_outlined, size: width * 0.06, color: Colors.red),
              title: Text('Report ${currentUser}', style: TextStyle(color: Colors.red, fontSize: width * 0.045)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, BuildContext context) {
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
