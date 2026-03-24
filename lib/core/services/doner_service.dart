import 'package:cloud_firestore/cloud_firestore.dart';

class DonorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getDonors() {
    return _firestore.collection('donors').snapshots();
  }

  Future<DocumentSnapshot> getDonorById(String donorId) {
    return _firestore.collection('donors').doc(donorId).get();
  }

  Future<List<QueryDocumentSnapshot>> searchDonors({
    String? bloodGroup,
    String? location,
  }) async {
    Query query = _firestore.collection('donors');
    
    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }
    
    final snapshot = await query.get();
    
    if (location != null && location.isNotEmpty) {
      return snapshot.docs.where((doc) {
        final docLocation = (doc['location'] ?? '').toString().toLowerCase();
        return docLocation.contains(location.toLowerCase());
      }).toList();
    }
    
    return snapshot.docs;
  }
}