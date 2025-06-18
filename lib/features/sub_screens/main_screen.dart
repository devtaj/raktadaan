import 'package:flutter/material.dart';
import 'package:raktadan/features/sub_screens/UserInfoScreen.dart';
import '../../../core/services/auth_service.dart'; // Adjust path
import 'package:cloud_firestore/cloud_firestore.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();

  void _onBloodBankTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Blood Bank')),
    );
  }

  void _onDonateNowTap() async {
    final user = _authService.currentUser;

    if (user == null) {
      // Not logged in, navigate to login
      Navigator.pushNamed(context, '/login');
    } else {
      // Logged in, fetch user info from Firestore
      try {
        final doc = await FirebaseFirestore.instance
            .collection('donors')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final name = data['name'] ?? 'No name';
          final bloodGroup = data['bloodGroup'] ?? 'Unknown';
          final registrationDate = data['createdAt']?.toDate() ?? DateTime.now();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserInfoScreen(
                userId: user.uid,
                name: name,
                bloodGroup: bloodGroup, registrationDate:registrationDate,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User profile data not found')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user info: $e')),
        );
      }
    }
  }

  void _onEmergencyTap() {
    Navigator.pushNamed(context, '/emergencyNumbers');
  }

  void _onEventsTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing Events')),
    );
  }

  Widget buildCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.red),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            buildCard(icon: Icons.bloodtype_outlined, label: "Blood Bank", onTap: _onBloodBankTap),
            buildCard(icon: Icons.volunteer_activism, label: "Donate Now", onTap: _onDonateNowTap),
            buildCard(icon: Icons.contact_emergency_rounded, label: "Emergency Numbers", onTap: _onEmergencyTap),
            buildCard(icon: Icons.event, label: "Events", onTap: _onEventsTap),
          ],
        ),
      ),
    );
  }
}
