import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequestStatusService {
  static Future<Map<String, dynamic>?> fetchRequestStatus(String requestId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bloodrequest')
          .doc(requestId)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching request status: $e');
      return null;
    }
  }

  static Stream<DocumentSnapshot> watchRequestStatus(String requestId) {
    return FirebaseFirestore.instance
        .collection('bloodrequest')
        .doc(requestId)
        .snapshots();
  }
}