import 'package:cloud_firestore/cloud_firestore.dart';

class DonationChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getChatStatus(String requestId) {
    return _firestore.collection('donation_chats').doc(requestId).snapshots();
  }

  Stream<QuerySnapshot> getChatMessages(String requestId) {
    return _firestore
        .collection('donation_chats')
        .doc(requestId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> updateStatus(String requestId, String status, String userId) async {
    await _firestore.collection('donation_chats').doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastUpdatedBy': userId,
    });

    await sendSystemMessage(requestId, 'Status updated to $status');
  }

  Future<void> sendMessage(String requestId, String message, String senderId) async {
    final messageData = {
      'text': message,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'message',
    };
    
    await _firestore
        .collection('donation_chats')
        .doc(requestId)
        .collection('messages')
        .add(messageData);
    
    // Also save to chat_history
    await _firestore
        .collection('chat_history')
        .doc(requestId)
        .collection('messages')
        .add(messageData);
  }

  Future<void> sendSystemMessage(String requestId, String message) async {
    await _firestore
        .collection('donation_chats')
        .doc(requestId)
        .collection('messages')
        .add({
      'text': message,
      'senderId': 'system',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'status',
    });
    
    // Also save to chat_history
    await _firestore
        .collection('chat_history')
        .doc(requestId)
        .collection('messages')
        .add({
      'text': message,
      'senderId': 'system',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'status',
    });
  }

  Future<List<QueryDocumentSnapshot>> getUserChats(String userId) async {
    final snapshot = await _firestore
        .collection('donation_chats')
        .where('receiverId', isEqualTo: userId)
        .get();
    
    final donorSnapshot = await _firestore
        .collection('donation_chats')
        .where('donorId', isEqualTo: userId)
        .get();

    return [...snapshot.docs, ...donorSnapshot.docs];
  }
}