import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raktadan/core/constants/app_constants.dart';
import 'package:raktadan/core/utils/error_handler.dart';
import 'package:raktadan/core/utils/validators.dart';

class BloodRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Future<void> acceptRequest({
    required String requestId,
    required String userId,
    required String donorId,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      if (requestId.trim().isEmpty) {
        throw Exception('Request ID cannot be empty');
      }
      if (!Validators.isValidId(userId) || !Validators.isValidId(donorId)) {
        throw Exception('Invalid user or donor ID');
      }

      final batch = _firestore.batch();
      
      // Update request status
      batch.update(
        _firestore.collection(AppConstants.requestNotificationsCollection).doc(requestId),
        {'status': AppConstants.statusAccepted}
      );
      
      // Send notification to donor
      batch.set(
        _firestore.collection(AppConstants.notificationsCollection).doc(),
        {
          'senderId': userId,
          'receiverId': donorId,
          'message': 'Your donation request has been accepted! Contact details: ${requestData['senderPhone'] ?? 'N/A'}',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'accept_request',
        }
      );
      
      // Create chat room with consistent ID
      final chatId = _generateChatId(donorId, userId);
      batch.set(
        _firestore.collection('chats').doc(chatId),
        {
          'donorId': donorId,
          'donorName': requestData['senderName'] ?? 'Unknown',
          'donorBloodGroup': requestData['senderBloodGroup'] ?? 'N/A',
          'requesterId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': 'Chat started',
          'lastMessageTime': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true)
      );
      

      
      await batch.commit();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      if (!Validators.isValidId(requestId)) {
        throw Exception('Invalid request ID');
      }
      await _firestore.collection(AppConstants.requestNotificationsCollection).doc(requestId).delete();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> openChat({
    required String requestId,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      if (!Validators.isValidId(requestId)) {
        throw Exception('Invalid request ID');
      }
      
      final batch = _firestore.batch();
      
      batch.set(
        _firestore.collection(AppConstants.savedRequestsCollection).doc(requestId),
        requestData
      );
      
      batch.delete(
        _firestore.collection(AppConstants.requestNotificationsCollection).doc(requestId)
      );
      
      await batch.commit();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> donateToRequest({
    required String requestId,
    required String donorId,
    required String requesterId,
    required Map<String, dynamic> donorData,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      if (!Validators.isValidId(donorId) || !Validators.isValidId(requesterId)) {
        throw Exception('Invalid donor or requester ID');
      }

      // Check if donor already sent request to this requester
      final existingRequest = await _firestore
          .collection(AppConstants.requestNotificationsCollection)
          .where('senderId', isEqualTo: donorId)
          .where('receiverId', isEqualTo: requesterId)
          .where('status', isEqualTo: AppConstants.statusPending)
          .get();
      
      if (existingRequest.docs.isNotEmpty) {
        throw Exception('You have already sent a request to this user');
      }

      final batch = _firestore.batch();
      
      // Send notification to requester
      batch.set(
        _firestore.collection(AppConstants.requestNotificationsCollection).doc(),
        {
          'senderId': donorId,
          'receiverId': requesterId,
          'senderName': donorData['name'] ?? 'Unknown Donor',
          'senderBloodGroup': donorData['bloodGroup'] ?? 'N/A',
          'senderLocation': donorData['location'] ?? 'N/A',
          'senderPhone': donorData['phoneNumber'] ?? 'N/A',
          'message': 'Someone wants to donate blood to your request',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'donation_offer',
          'status': AppConstants.statusPending,
          'originalRequestId': requestId,
          'seen': false,
        }
      );
      
      await batch.commit();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> markNotificationsAsSeen(String userId) async {
    try {
      final notifications = await _firestore
          .collection(AppConstants.requestNotificationsCollection)
          .where('receiverId', isEqualTo: userId)
          .where('seen', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'seen': true});
      }
      
      await batch.commit();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Add message
      batch.set(
        _firestore.collection('chats').doc(chatId).collection('messages').doc(),
        {
          'senderId': senderId,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'seen': false,
        }
      );
      
      // Update chat with last message and unread count
      batch.update(
        _firestore.collection('chats').doc(chatId),
        {
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount_$receiverId': FieldValue.increment(1),
        }
      );
      
      await batch.commit();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> markMessagesAsSeen(String chatId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      // Mark messages as seen
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('seen', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .get();
      
      for (final doc in messages.docs) {
        batch.update(doc.reference, {'seen': true});
      }
      
      // Reset unread count for this user
      batch.update(
        _firestore.collection('chats').doc(chatId),
        {'unreadCount_$userId': 0}
      );
      
      await batch.commit();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}