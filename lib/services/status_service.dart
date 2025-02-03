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

// Mark Status as Viewed
  Future<void> markStatusAsViewed(String statusOwnerId) async {
    String viewerId = _auth.currentUser!.uid;
    DocumentSnapshot viewerDoc = await _firestore.collection('Users').doc(viewerId).get();
    String viewerName = viewerDoc.exists ? viewerDoc['firstName'] : "Unknown";

    DocumentReference statusRef = _firestore.collection('Status').doc(statusOwnerId);
    await statusRef.update({
      'viewedBy': FieldValue.arrayUnion([viewerName])
    });
  }
}
