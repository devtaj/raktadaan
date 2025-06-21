import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequestList extends StatefulWidget {
  const BloodRequestList({super.key});

  @override
  State<BloodRequestList> createState() => _BloodRequestListState();
}

class _BloodRequestListState extends State<BloodRequestList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blood Requests'),
      actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to AddEventScreen (replace with your route)
                Navigator.pushNamed(context, '/bloodRequest');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 2,
              ),
              child: const Text('Blood Request'),
            ),
          ),
        ],),
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
              final name = data['name'] ?? 'N/A';
              final phone = data['phone'] ?? 'N/A';
              final location = data['location'] ?? 'N/A';
              final hospital = data['hospital'] ?? 'N/A';
              final bloodGroup = data['bloodGroup'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ListTile(
                  leading: const Icon(Icons.bloodtype, color: Colors.red),
                  title: Text('$name - $bloodGroup'),
                  subtitle: Text('Hospital: $hospital\nLocation: $location\nPhone: $phone'),
                  isThreeLine: true,
                  // You can add onTap for more details or actions
                ),
              );
            },
          );
        },
      ),
    );
  }
}
