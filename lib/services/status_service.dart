import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Status.dart';

class StatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> uploadStatus(String text, String backgroundColor,String textStyle) async {
    String uid = _auth.currentUser!.uid;


    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(uid).get();
    if (!userDoc.exists) {
      print("Error: User document not found!");
      return;
    }

    String username = userDoc['firstName'] ?? "Unknown";

    Status status = Status(
      uid: uid,
      username: username,
      text: text,
      backgroundColor: backgroundColor,
      textStyle: textStyle, // Store selected text style
      timestamp: Timestamp.now(),
      viewedBy: [],
      statusReply: [],

    );

    await _firestore.collection('Status').add(status.toMap());
    print("Status uploaded successfully with color: $backgroundColor and style: $textStyle");
  }

  Stream<List<Status>> getStatuses() {
    return _firestore.
    collection('Status').
        where('timestamp',isGreaterThan: Timestamp.now().toDate().subtract(Duration(hours: 24)))
    .orderBy('timestamp',
        descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Status.fromMap(doc.data())).toList();
    });
  }
  Future<void> sendStatusReply(String statusId, String receiverId, String replyText) async {
    String senderId = _auth.currentUser!.uid;
    DocumentSnapshot senderDoc = await _firestore.collection('Users').doc(senderId).get();
    if (!senderDoc.exists) {
      print("Error: Sender document not found!");
      return;
    }

    String senderName = senderDoc['firstName'] ?? "Unknown"; // Get sender's name
    DocumentReference statusRef = _firestore.collection('Status').doc(statusId);
    await statusRef.update({
      'statusReply': FieldValue.arrayUnion([
        {'replyBy': senderName, 'replyText': replyText} // Store name instead of ID
      ])
    });

    print("Reply added successfully: $senderName - $replyText");
  }


  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1\_$user2' : '$user2\_$user1';
  }

  Future<void> markStatusAsViewed(String statusOwnerId) async {
    String viewerId = _auth.currentUser!.uid;
    DocumentSnapshot viewerDoc = await _firestore.collection('Users').doc(viewerId).get();
    String viewerName = viewerDoc.exists ? viewerDoc['firstName'] : "Unknown";

    DocumentReference statusRef = _firestore.collection('Status').doc(statusOwnerId);
    await statusRef.update({
      'viewedBy': FieldValue.arrayUnion([viewerName]),

    });
  }
}
