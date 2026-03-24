import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raktadan/core/services/auth_service.dart';
import 'package:raktadan/core/services/blood_request_service.dart';
import 'package:raktadan/core/utils/error_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class BloodRequestList extends StatefulWidget {
  const BloodRequestList({super.key});

  @override
  State<BloodRequestList> createState() => _BloodRequestListState();
}

class _BloodRequestListState extends State<BloodRequestList> {
  final BloodRequestService _requestService = BloodRequestService();

  // Function to send donation request with donor details
  Future<bool> sendDonationRequest(
      String receiverUserId, String requestId) async {
    try {
      final currentUser = AuthService().currentUser;

      if (currentUser == null) {
        print('❌ No authenticated user found.');
        return false;
      }

      // Fetch donor profile from "donors" collection
      final donorDoc = await FirebaseFirestore.instance
          .collection('donors')
          .doc(currentUser.uid)
          .get();

      if (!donorDoc.exists) {
        print('⚠ Donor profile not found in Firestore.');
        return false;
      }

      final donorData = donorDoc.data() ?? {};

      // Build request data
      final requestData = {
        'senderId': currentUser.uid,
        'senderName': donorData['name'] ?? '',
        'senderPhone': donorData['phone'] ?? '',
        'senderAddress': donorData['address'] ?? '',
        'senderBloodGroup': donorData['bloodGroup'] ?? '',
        'senderLocation': donorData['location'] ?? '',
        'receiverId': receiverUserId,
        'requestId': requestId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'notificationType': 'donation_request',
        'isRead': false, // for notification tracking
      };

      // 1️⃣ Save donation request under receiver’s account
      await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUserId)
          .collection('received_requests')
          .add(requestData);

      // 2️⃣ Also save into a global "request_notifications" collection
      await FirebaseFirestore.instance
          .collection('request_notifications')
          .add(requestData);

      print('✅ Donation request sent & notification created.');
      return true;
    } catch (e, stack) {
      print('❌ Error sending donation request: $e');
      print(stack);
      return false;
    }
  }

  // Helper to get color for status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'fulfilled':
        return Colors.green;
      case 'in_process':
        return Colors.orange;
      default:
        return Colors.red; // pending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Requests'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bloodRequest');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 1, 92, 39),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text('Blood Request'),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bloodrequest')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No blood requests found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final requestId = docs[index].id;
              final name = data['name'] ?? 'N/A';
              final phone = data['phone'] ?? 'N/A';
              final location = data['location'] ?? 'N/A';
              final hospital = data['hospital'] ?? 'N/A';
              final bloodGroup = data['bloodGroup'] ?? 'N/A';
              final qty = data['qty'] ?? 'N/A';
              final caseDetail = data['case'] ?? 'N/A';
              final receiverUserId = data['postedByUserId'] ?? '';
              final status = data['status'] ?? 'pending';

              final shareMessage = '🚨 Blood Request 🚨\n\n'
                  'Required Blood Group: $bloodGroup\n'
                  'Patient Name: $name\n'
                  'Hospital: $hospital\n'
                  'Location: $location\n'
                  'Required Qty: $qty unit(s)\n'
                  'Case: $caseDetail\n'
                  'Contact: $phone\n';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bloodtype, color: Colors.red),
                        title: Text(
                          'Required Blood: $bloodGroup',
                          style: const TextStyle(color: Colors.red),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: $name'),
                            Text('Hospital: $hospital'),
                            Text('Location: $location'),
                            Text('Phone: $phone'),
                            Text('Required Qty: $qty'),
                            Text('Case: $caseDetail'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text("Status: "),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              try {
                                if (receiverUserId.isEmpty) {
                                  ErrorHandler.showError(context, 'Invalid request - missing user ID');
                                  return;
                                }

                                final currentUser = AuthService().currentUser;
                                if (currentUser == null) {
                                  ErrorHandler.showError(context, 'Please login to donate');
                                  return;
                                }

                                final donorDoc = await FirebaseFirestore.instance
                                    .collection('donors')
                                    .doc(currentUser.uid)
                                    .get();

                                if (!donorDoc.exists) {
                                  ErrorHandler.showError(context, 'Donor profile not found');
                                  return;
                                }

                                final donorData = donorDoc.data() ?? {};

                                await _requestService.donateToRequest(
                                  requestId: requestId,
                                  donorId: currentUser.uid,
                                  requesterId: receiverUserId,
                                  donorData: donorData,
                                  requestData: data,
                                );

                                if (mounted) {
                                  ErrorHandler.showSuccess(context, 'Donation request sent successfully!');
                                }
                              } catch (e) {
                                if (mounted) {
                                  ErrorHandler.showError(context, 'Failed to send donation request: ${e.toString()}');
                                }
                              }
                            },
                            icon: const Icon(Icons.favorite),
                            label: const Text('Donate'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final Uri callUri = Uri(scheme: 'tel', path: phone);
                              if (await canLaunchUrl(callUri)) {
                                await launchUrl(callUri);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Could not launch dialer')),
                                );
                              }
                            },
                            icon: const Icon(Icons.call),
                            label: const Text('Call'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 9, 43, 71),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              await Share.share(shareMessage);
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
