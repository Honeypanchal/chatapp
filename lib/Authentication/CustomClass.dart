class CustomClass {
  String firstName;
  String lastName;
String uid;

  String email;

  String? password;
  String? photoURL;

  CustomClass(
      {required this.firstName,
      required this.lastName,
required this.uid,
      required this.email,
      this.password,
      this.photoURL});
}
