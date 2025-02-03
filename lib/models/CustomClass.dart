class CustomClass {
  String firstName;

  String uid;

  String email;
String? profilePicture;
  List<Map<String,dynamic>?>? groups;
  List<String?>? activeChats;
 List<String?>? notifications;
bool isActive=true;

  String? password;


  CustomClass(
      {required this.firstName,

required this.uid,
      required this.email,

      this.password,
     this.profilePicture,
       required  this.groups,
required this.activeChats
      });

  void addGroupAndAddActiveGroup(String groupId, bool isAdmin) {
    print("Adding group: $groupId");

    if (groups == null) {
      groups = [];
      print("Groups list was null, initializing...");
    }

    bool groupExists = groups!.any((group) => group!["groupId"] == groupId);

    if (!groupExists) {
      groups!.add({"groupId": groupId, "admin": isAdmin});
      print("Group added successfully! Total groups: ${groups!.length}");
    } else {
      print("Group already exists!");
    }
  }


  Map<String, dynamic> toMap() {
    return {
      "firstName": firstName,
      "uid": uid,
      "email": email,
      "password": password,
      "profilePic": profilePicture,
      "groups": groups,
      "activeChats": activeChats,
      "notifications": notifications,
      "isActive": isActive,
    };
  }
}


