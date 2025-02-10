import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Status.dart';

class StatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> uploadStatus(String text, String backgroundColor, String textStyle) async {
    String userId = _auth.currentUser!.uid;

    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userId).get();
    if (!userDoc.exists) {
      print("Error: User document not found!");
      return;
    }

    String username = userDoc['firstName'] ?? "Unknown";

    DocumentReference statusRef = _firestore.collection('Status').doc();
    Status status = Status(
      uid: statusRef.id,
      userId: userId,
      username: username,
      text: text,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
      timestamp: Timestamp.now(),
      viewedBy: [],
      statusReplies: [],
    );

    await statusRef.set(status.toMap());
    print("Status uploaded successfully with ID: ${statusRef.id}");
  }


  Future<void> sendStatusReply(String statusId, String replyText) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    String senderId = currentUser.uid;

    DocumentSnapshot senderDoc = await _firestore.collection('Users').doc(senderId).get();
    if (!senderDoc.exists) {

      return;
    }

    String senderName = senderDoc['firstName'] ?? "Unknown";

    DocumentReference statusRef = _firestore.collection('Status').doc(statusId);
    DocumentSnapshot statusDoc = await statusRef.get();
    if (!statusDoc.exists) {

      return;
    }

    try {
      await statusRef.update({
        'statusReplies': FieldValue.arrayUnion([
          {
            'replyBy': senderName,
            'replyText': replyText,
            'timestamp': Timestamp.now(),
          }
        ])
      });
      print("Reply added successfully: $senderName - $replyText");
    } catch (e) {
      print(" Error sending reply: $e");
    }
  }


  Stream<List<Status>> getStatuses() {

    return _firestore.collection('Status').
    where('timestamp',isGreaterThan: Timestamp.now().toDate().subtract(Duration(hours: 24)))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {

    })
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        // print(" Status Data: ${doc.id} -> $data");
        return Status.fromMap(data);
      }).toList();
    });
  }

  void fetchAndPrintStatuses() async {
    var snapshot = await _firestore.collection('Status').get();
    if (snapshot.docs.isEmpty) {
      print("No statuses found in Firestore!");
    } else {
      for (var doc in snapshot.docs) {
        // print("Status Found: ${doc.id} -> ${doc.data()}");
      }
    }
  }
  Future<void> deleteStatus(String statusId) async {
    try {
      await FirebaseFirestore.instance.collection('Status').doc(statusId).delete();
    } catch (e) {
      print("Error deleting status: $e");
    }
  }



  void debugFetchStatuses() async {
    var snapshot = await _firestore.collection('Status').get();
    for (var doc in snapshot.docs) {
      print("Fetched status: ${doc.id} -> ${doc.data()}");
    }
  }



  Future<void> markStatusAsViewed(String statusId, String userId) async {
    try {
      DocumentReference statusRef = FirebaseFirestore.instance.collection('Status').doc(statusId);
      DocumentSnapshot statusDoc = await statusRef.get();

      if (statusDoc.exists) {
        await statusRef.update({
          'viewedBy': FieldValue.arrayUnion([userId])
        });
        print(" Marked as viewed successfully for: $statusId");
      } else {
        print(" Status document not found in Firestore: $statusId");
      }
    } catch (e) {
      print(" Error marking as viewed: $e");
    }
  }




}