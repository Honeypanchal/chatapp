class CustomClass {
  String firstName;

  String uid;

  String email;
String? profilePicture;
  List<String?>? groups;
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

      });

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


