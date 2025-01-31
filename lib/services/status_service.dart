import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Status.dart';

class StatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload Status
  Future<void> uploadStatus(List<String> imageUrls) async {
    String uid = _auth.currentUser!.uid;
    String username = _auth.currentUser!.displayName ?? "Unknown";
    String photoUrl = _auth.currentUser!.photoURL ?? "";

   Status status= Status(uid: uid,
       username: username,
       photoUrl: photoUrl,
       statusImageUrls: imageUrls,
       timestamp: Timestamp.now(),
       viewBy: []
   );

    await _firestore.collection('statuses').doc(uid).set(status.toMap());
  }

  // Fetch All Statuses
  Stream<List<Status>> getStatuses() {
    return _firestore.collection('statuses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Status.fromMap(doc.data())).toList();
    });
  }

  // Mark Status as Viewed
  Future<void> markStatusAsViewed(String statusOwnerId) async {
    String viewerId = _auth.currentUser!.uid;

    DocumentReference statusRef = _firestore.collection('statuses').doc(statusOwnerId);

    await statusRef.update({
      'viewedBy': FieldValue.arrayUnion([viewerId])
    });
  }
}