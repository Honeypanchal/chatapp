import 'package:chatapp/models/CustomClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _cloudFirestore = FirebaseFirestore.instance.collection('Users');
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<CustomClass?> signUpUser(
    String firstName,


    String email,
    String password) async {
  try {
    UserCredential user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (user.user != null) {
      CustomClass newUser = CustomClass(
        uid: user.user!.uid,
          firstName: firstName,
          email: email,
          password: password,
        activeChats:null,
        groups: null,
      );
      await _cloudFirestore.doc(user.user!.uid).set({
        "uid": user.user!.uid,
        "firstName": firstName,
        "status": "unavailable",//changes

        "email": email,
        "password": password,
        "profilePic": "",
        "groups": [],
        "activeChats": [],
        "notifications": [],
        "createdAt": DateTime.timestamp().millisecondsSinceEpoch,
        "isActive": true
      });
      return newUser;
    }
  } catch (e) {
    print("Error signing up: $e");

    throw Exception("Error signing up: ${e.toString()}");
  }
  return null;
}

Future<CustomClass?> signInUser(String email, String password) async {
  try {
    UserCredential user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (user.user != null) {
      final foundUser = await _cloudFirestore.doc(user.user!.uid).get();
      if (foundUser.exists) {
        CustomClass newUser = CustomClass(
          uid: foundUser['uid'],
          firstName: foundUser['firstName'],


          email: foundUser['email'],
          password: foundUser['password'],
          activeChats: null,
          groups:null
        );
        // photoURL: foundUser['photoURL']);

        return newUser;
      }
    }
  } catch (e) {
    print("Error signing in: $e");
    throw Exception("Error signing in: ${e.toString()}");
  }
  return null;
}

Future<CustomClass?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      print('Sign-in aborted by user.');
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    User? user = userCredential.user;
    if (user != null) {
      print('Google Sign-In successful');
      print('User Name: ${user.displayName}');
      print('User Email: ${user.email}');
      print('User Profile Picture: ${user.photoURL}');

      _cloudFirestore.doc(user.uid).set({
"uid":user.uid,

        "firstName": user.displayName!,
        "status": "unavailable",//changes


        "email": user.email!,
        "profilePic": "",
        "groups": null,
        "activeChats":null,
        "notifications":null,
        "createdAt": DateTime.timestamp().millisecondsSinceEpoch,
        "isActive": true
      });
      CustomClass newUser = CustomClass(
uid: user.uid,

          firstName: user.displayName!,

          email: user.email!,
        activeChats: [],
        groups: [],
      );
      return newUser;
    }
  } catch (e) {
    print("Error during Google Sign-In: $e");
    throw Exception("Error during Google Sign-In: ${e.toString()}");

  }
  return null;
}
