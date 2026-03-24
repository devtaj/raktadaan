import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final user = AuthService().currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    return await FirebaseFirestore.instance
        .collection('donors')
        .doc(user.uid)
        .get();
  }

  Future<void> _deleteRequest(String docId) async {
    await FirebaseFirestore.instance
        .collection('bloodrequest')
        .doc(docId)
        .delete();

    // also delete progress tracking if exists
    await FirebaseFirestore.instance
        .collection('donation_progress')
        .doc(docId)
        .delete();
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    // Update donation_progress safely
    await FirebaseFirestore.instance
        .collection('donation_progress')
        .doc(docId)
        .set({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    // Update bloodrequest safely
    await FirebaseFirestore.instance.collection('bloodrequest').doc(docId).set({
      'status': newStatus,
    }, SetOptions(merge: true));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'fulfilled':
        return Colors.green;
      case 'donating':
        return Colors.orange;
      case 'on_the_way':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.red; // pending
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return "Pending";
      case 'on_the_way':
        return "On the Way";
      case 'donating':
        return "Donating";
      case 'fulfilled':
        return "Fulfilled";
      case 'cancelled':
        return "Cancelled";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userEmail = user.email ?? 'N/A';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Info
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return const Text('Something went wrong. Please try again.');
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text('No profile data found.');
                }

                final data = snapshot.data!.data()!;
                final name = data['name'] ?? 'N/A';
                final phone = data['phoneNumber'] ?? 'N/A';
                final bloodGroup = data['bloodGroup'] ?? 'N/A';
                final location = data['location'] ?? 'N/A';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 80, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: $userEmail',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text('Phone: $phone', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text(
                      'Blood Group: $bloodGroup',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Location: $location',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    const Divider(thickness: 2),
                    const SizedBox(height: 10),
                    const Text(
                      'Your Blood Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),

            // User's Blood Requests
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('bloodrequest')
                  .where('postedByUserId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Text('Failed to load blood requests.');
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Text(
                    'You haven\'t submitted any blood requests yet.',
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final bloodGroup = data['bloodGroup'] ?? 'N/A';
                    final hospital = data['hospital'] ?? 'N/A';
                    final location = data['location'] ?? 'N/A';
                    final qty = data['qty']?.toString() ?? 'N/A';
                    final caseDetail = data['case'] ?? 'N/A';
                    final status = data['status'] ?? 'pending';
                    final timestamp = data['timestamp'] is Timestamp
                        ? (data['timestamp'] as Timestamp).toDate()
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.bloodtype, color: Colors.red),
                        title: Text('Blood Group: $bloodGroup'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hospital: $hospital'),
                            Text('Location: $location'),
                            Text('Qty: $qty units'),
                            Text('Case: $caseDetail'),
                            if (timestamp != null)
                              Text('Posted: ${timestamp.toLocal()}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text("Status: "),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _formatStatus(status),
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
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Request'),
                                  content: const Text(
                                    'Are you sure you want to delete this blood request?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _deleteRequest(doc.id);
                              }
                            } else {
                              // Update status
                              await _updateStatus(doc.id, value);
                            }
                          },

                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'pending',
                              child: Text('Mark as Pending'),
                            ),
                            const PopupMenuItem(
                              value: 'on_the_way',
                              child: Text('Mark as On The Way'),
                            ),
                            const PopupMenuItem(
                              value: 'donating',
                              child: Text('Mark as Donating'),
                            ),
                            const PopupMenuItem(
                              value: 'fulfilled',
                              child: Text('Mark as Fulfilled'),
                            ),
                            const PopupMenuItem(
                              value: 'cancelled',
                              child: Text(
                                'Mark as Cancelled',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete Request',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
