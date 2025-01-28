import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/Group.dart';


CollectionReference groupsDb= FirebaseFirestore.instance.collection("groups");


Future<void> createNewGroup()async{

}