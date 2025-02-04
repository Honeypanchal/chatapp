import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupDisplayPage extends StatefulWidget {
  final String currentUser;
  const GroupDisplayPage({super.key, required this.currentUser});

  @override
  State<GroupDisplayPage> createState() => _GroupDisplayPageState();
}

class _GroupDisplayPageState extends State<GroupDisplayPage> {

  TextEditingController _searchText = TextEditingController();
  CollectionReference groupsDB = FirebaseFirestore.instance.collection("groups");
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchText.addListener(() {
    fetchGroups();
    });
  }
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchGroups() {
    Query query = groupsDB.where("participants", arrayContains: widget.currentUser);

    if (_searchText.text.isNotEmpty) {

      String searchTerm = _searchText.text.toLowerCase();

      String searchLowerBound = searchTerm;
      String searchUpperBound = searchTerm + '\uf8ff';

      query = query.where("groupNameLower", isGreaterThanOrEqualTo: searchLowerBound)
          .where("groupNameLower", isLessThan: searchUpperBound);
    }

    return query.snapshots().map((querySnapshot) =>
    querySnapshot.docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>);
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: width * 0.064),
          child: Icon(Icons.groups_outlined, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
           'Groups',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: width > 600 ? width * 0.05 : width * 0.06,
              ),
            ),

          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: width * 0.01,
              right: width * 0.01,
              top: height * 0.018,
            ),
            child: Container(
              height: height * 0.052,
              width: width * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
              child: TextField(
                controller: _searchText,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Raleway',
                ),
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.025),
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: fetchGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.green.shade400, // WhatsApp-like green
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error fetching groups"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No groups found"));
                }

                var groups = snapshot.data!;
                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    var groupData = groups[index].data();
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        child: Icon(Icons.group, color: Colors.green.shade400),
                      ),
                      title: Text(groupData["groupName"] ?? "Unnamed Group"),
                      subtitle: Text("Members: ${groupData["participants"].length}"),
                      onTap: () {
                        // Handle group click
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/newGroup',
            arguments: {'currentUser': widget.currentUser},
          );
        },
        backgroundColor: Colors.black,
        tooltip: 'Create New Group',
        child: Icon(
          Icons.group_add,
          color: Colors.green.shade400,
          size: width < 600 ? width * 0.08 : width * 0.09,
        ),
      ),
    );
  }
}
