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

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService().currentUser?.email ?? 'N/A';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Email: $userEmail', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Phone: $phone', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Blood Group: $bloodGroup', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Location: $location', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _logout(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
