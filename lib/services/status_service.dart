import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Status.dart';

class StatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload Text Status
  Future<void> uploadStatus(String text) async {
    String uid = _auth.currentUser!.uid;

    // Fetch user data from Firestore
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
      timestamp: Timestamp.now(),
      viewedBy: [],
    );

    // Store status under the user's UID (overwrite old status)
    await _firestore.collection('Status').doc(uid).set(status.toMap());

    print("Text Status added successfully!");
  }

  // Fetch all statuses
  Stream<List<Status>> getStatuses() {
    return _firestore
        .collection('Status')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
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
