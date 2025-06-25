import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raktadan/core/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class BloodRequestList extends StatefulWidget {
  const BloodRequestList({super.key});

  @override
  State<BloodRequestList> createState() => _BloodRequestListState();
}

class _BloodRequestListState extends State<BloodRequestList> {
  // Function to send donation request
  Future<bool> sendDonationRequest(String receiverUserId, String requestId) async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return false;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUserId)
          .collection('received_requests')
          .add({
        'senderId': currentUser.uid,
        'requestId': requestId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      return true;
    } catch (e) {
      print('Error sending request: $e');
      return false;
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

              // Share message text
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
                        subtitle: Text(
                          'Name: $name\n'
                          'Hospital: $hospital\n'
                          'Location: $location\n'
                          'Phone: $phone\n'
                          'Required Qty: $qty\n'
                          'Case: $caseDetail',
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invalid request - missing user ID')),
                                  );
                                  return;
                                }

                                bool isSent = await sendDonationRequest(receiverUserId, requestId);

                                if (isSent) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Request sent successfully!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Could not send request')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
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
                                  const SnackBar(content: Text('Could not launch dialer')),
                                );
                              }
                            },
                            icon: const Icon(Icons.call),
                            label: const Text('Call'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 9, 43, 71),
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
