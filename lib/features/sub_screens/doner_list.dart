import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorListScreen extends StatefulWidget {
  const DonorListScreen({super.key});

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  Future<void> _refreshData() async {
    setState(() {}); // Triggers StreamBuilder to rebuild
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
      );
    }
  }

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donor List')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by location, or blood group',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // Donor List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('donors').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No donors found.'));
                  }

                  // Apply search filter
                  final donors = snapshot.data!.docs.where((doc) {
                    final name = (doc['name'] ?? '').toString().toLowerCase();
                    final location = (doc['location'] ?? '').toString().toLowerCase();
                    final bloodGroup = (doc['bloodGroup'] ?? '').toString().toLowerCase();

                    return name.contains(searchQuery) ||
                        location.contains(searchQuery) ||
                        bloodGroup.contains(searchQuery);
                  }).toList();

                  if (donors.isEmpty) {
                    return const Center(child: Text('No matching donors.'));
                  }

                  return ListView.builder(
                    itemCount: donors.length,
                    itemBuilder: (context, index) {
                      final donor = donors[index];
                      final name = donor['name'] ?? 'No Name';
                      final phone = donor['phoneNumber'] ?? 'No Phone';
                      final location = donor['location'] ?? 'No Location';
                      final bloodGroup = donor['bloodGroup'] ?? 'Unknown';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade100,
                            child: Text(
                              bloodGroup,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Phone: $phone\nLocation: $location'),
                          trailing: IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () {
                              _launchDialer(phone);
                            },
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
