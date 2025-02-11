// import 'package:chatapp/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ContectInfo extends StatelessWidget {
  final String currentUser;
  final String email;

  const ContectInfo(
      {super.key, required this.currentUser, required this.email});

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
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
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
                radius: kIsWeb ? width * 0.025 : width * 0.13,
                backgroundColor: Colors.green[700],
                child: Text(
                  currentUser[0].toUpperCase(),
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: kIsWeb ? 33 : 38,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: kIsWeb ? height * 0.005 : height * 0.012),
            Text(currentUser,
                style: TextStyle(
                    fontSize: kIsWeb ? width * 0.020 : width * 0.055)),
            Text(email,
                style: TextStyle(color: Colors.grey, fontSize:
                kIsWeb ? width * 0.020 : width * 0.042)),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(Icons.call, 'Audio', context),
                _buildButton(Icons.videocam, 'Video', context),
                _buildButton(Icons.currency_rupee_outlined, 'Pay', context),
                _buildButton(Icons.search, 'Search', context),
              ],
            ),
            SizedBox(height: height * 0.012),
            Divider(color: Colors.grey.shade100, thickness: height * 0.007),
            ListTile(
              leading: Icon(
                Icons.notifications_none,
                size:kIsWeb ? width * 0.02 : width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal:kIsWeb ? width * 0.020 : width * 0.012),
                child: Text(
                  'Notifications',
                  style: TextStyle(fontSize: kIsWeb ? width * 0.02 :width * 0.045),
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                size: kIsWeb ? width * 0.02 : width * 0.07,
              ),
            ),
            ListTile(
              leading: Icon(Icons.image_outlined, size:kIsWeb ? width * 0.020 : width * 0.06),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal:kIsWeb ? width * 0.020 : width * 0.012),
                child: Text('Media visibility',
                    style: TextStyle(fontSize:kIsWeb ? width * 0.020 : width * 0.045)),
              ),
              trailing: Icon(
                Icons.chevron_right,
                size:kIsWeb ? width * 0.020 : width * 0.07,
              ),
            ),
            ListTile(
              leading: Icon(Icons.star_border, size:kIsWeb ? width * 0.020 : width * 0.06),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal:kIsWeb ? width * 0.020 : width * 0.012),
                child: Text('Starred messages',
                    style: TextStyle(fontSize: kIsWeb ? width * 0.020 :width * 0.045)),
              ),
              trailing: Icon(
                Icons.chevron_right,
                size:kIsWeb ? width * 0.020 : width * 0.07,
              ),
            ),
            Divider(color: Colors.grey.shade100, thickness: height * 0.007),
            ListTile(
              leading: Icon(
                Icons.lock_outline,
                size:kIsWeb ? width * 0.020 : width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal:kIsWeb ? width * 0.020 : width * 0.012),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encryption',
                      style: TextStyle(fontSize:kIsWeb ? width * 0.020 : width * 0.045),
                    ),
                    Container(
                        width: width * 0.6,
                        child: Text(
                            "Messages and calls are end-to-end encrypted.",
                            style: TextStyle(
                                fontSize: kIsWeb ? width * 0.012 :width * 0.035, color: Colors.grey)))
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.timer_outlined,
                size:kIsWeb ? width * 0.020 : width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal:kIsWeb ? width * 0.020 : width * 0.012),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disappearing messages',
                        style: TextStyle(fontSize: kIsWeb ? width * 0.020 :width * 0.045)),
                    Text("off",
                        style: TextStyle(
                            fontSize:kIsWeb ? width * 0.012 : width * 0.035, color: Colors.grey))
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.mail_lock_outlined,
                size:kIsWeb ? width * 0.020 : width * 0.06,
              ),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.012),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chat lock',
                        style: TextStyle(fontSize:kIsWeb ? width * 0.020 : width * 0.045)),
                    Text("Lock and hide this chat on this device",
                        style: TextStyle(
                            fontSize: kIsWeb ? width * 0.012 :width * 0.035, color: Colors.grey))
                  ],
                ),
              ),
              trailing: Transform.scale(
                  scale: kIsWeb ? width * 0.0005 : width * 0.002,
                  child: Switch(
                    value: false,
                    onChanged: (val) {},
                    activeColor: Colors.black,
                  )),
            ),
            Divider(color: Colors.grey.shade100, thickness: height * 0.007),
            ListTile(
              leading: Icon(Icons.favorite_outline, size:kIsWeb ? width * 0.020 : width * 0.06),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal:kIsWeb ? width * 0.020 : width * 0.012),
                child: Text('Add to Favourites',
                    style: TextStyle(fontSize:kIsWeb ? width * 0.020 : width * 0.045)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.people_outline, size:kIsWeb ? width * 0.020 : width * 0.06),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal:kIsWeb ? width * 0.020 : width * 0.012),
                child: Text('Add to list',
                    style: TextStyle(fontSize:kIsWeb ? width * 0.020 : width * 0.045)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.block_flipped,
                  size: kIsWeb ? width * 0.020 :width * 0.06, color: Colors.red),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal:kIsWeb ? width * 0.020 : width * 0.012),
                child: Text('Block ${currentUser}',
                    style: TextStyle(color: Colors.red, fontSize:kIsWeb ? width * 0.020 : width * 0.045)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.thumb_down_alt_outlined,
                  size: kIsWeb ? width * 0.020 :width * 0.06, color: Colors.red),
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal:kIsWeb ? width * 0.020 : width * 0.012),
                child: Text('Report ${currentUser}',
                    style: TextStyle(color: Colors.red, fontSize: kIsWeb ? width * 0.020 :width * 0.045)),
              ),
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
