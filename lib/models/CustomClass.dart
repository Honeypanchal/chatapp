class CustomClass {
  String firstName;
  String lastName;
String uid;
  String gender;
  String email;

  String? password;
  String? photoURL;

  CustomClass(
      {required this.firstName,
      required this.lastName,
required this.uid,
      required this.email,
        required this.gender,
      this.password,
      this.photoURL});
}
