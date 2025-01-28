import 'package:flutter/material.dart';

class NewGroupDefinition extends StatelessWidget {

  final List<dynamic> members;

   NewGroupDefinition({super.key,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    TextEditingController _groupName = new TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
        backgroundColor:  Colors.green, // WhatsApp color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Name Section
              TextFormField(
                controller: _groupName,
                decoration: InputDecoration(
                  hintText: 'Group Name'
                ),
                style: TextStyle(
                  fontSize: width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: height * 0.02),
              // Permissions Section
              Text(
                'Group Permissions',
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Admins can edit group name and add/remove members',
                style: TextStyle(
                  fontSize: width * 0.045,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: height * 0.03),
              // Member Count Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${members.length} Members',
                    style: TextStyle(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Edit Group logic here
                    },
                  )
                ],
              ),
              SizedBox(height: height * 0.02),
              // Member Profiles Section
              Container(
                height: height * 0.3, // Adjusted height for members list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: width * 0.1, // Adjusted size for avatars
                            backgroundImage: AssetImage(members[index]['profilePic']!),
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            members[index]['name']!,
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
    );
  }
}
