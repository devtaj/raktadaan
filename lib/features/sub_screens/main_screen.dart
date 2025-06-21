import 'package:flutter/material.dart';
import 'package:raktadan/features/sub_screens/UserInfoScreen.dart';
import '../../../core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();

  String? latestEventTitle;
  String? latestEventDescription;

  String? latestDonorName;

  @override
  void initState() {
    super.initState();
    _fetchLatestEvent();
    _fetchLatestDonor();
  }

  Future<void> _fetchLatestEvent() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          latestEventTitle = doc['title'] ?? 'No Title';
          latestEventDescription = doc['description'] ?? '';
        });
      } else {
        setState(() {
          latestEventTitle = 'No recent events';
          latestEventDescription = 'Stay tuned for upcoming events.';
        });
      }
    } catch (e) {
      setState(() {
        latestEventTitle = 'Error loading event';
        latestEventDescription = e.toString();
      });
    }
  }

  Future<void> _fetchLatestDonor() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('donors')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          latestDonorName = doc['name'] ?? 'New Donor';
        });
      } else {
        setState(() {
          latestDonorName = 'No new donors yet';
        });
      }
    } catch (e) {
      setState(() {
        latestDonorName = 'Error loading donor: $e';
      });
    }
  }

  void _onBloodBankTap() {
    Navigator.pushNamed(context, '/bloodBanks');
  }

  void _onDonateNowTap() async {
    final user = _authService.currentUser;

    if (user == null) {
      Navigator.pushNamed(context, '/login');
    } else {
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
                bloodGroup: bloodGroup,
                registrationDate: registrationDate,
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
    Navigator.pushNamed(context, '/addEvent');
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

  Widget buildBannerCard({
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      color: Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grid Menu
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    buildCard(
                        icon: Icons.bloodtype_outlined,
                        label: "Blood Bank",
                        onTap: _onBloodBankTap),
                    buildCard(
                        icon: Icons.volunteer_activism,
                        label: "Be a Donor",
                        onTap: _onDonateNowTap),
                    buildCard(
                        icon: Icons.contact_emergency_rounded,
                        label: "Emergency Numbers",
                        onTap: _onEmergencyTap),
                    buildCard(
                        icon: Icons.event,
                        label: "Blood Donation Events",
                        onTap: _onEventsTap),
                  ],
                ),
              ),

              // Banners Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  "Latest Events & Updates",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // Latest event banner (dynamic)
              buildBannerCard(
                title: latestEventTitle ?? 'Loading...',
                description: latestEventDescription ?? '',
              ),

              // Latest donor welcome banner
              buildBannerCard(
                title: latestDonorName != null
                    ? 'Welcome, $latestDonorName!'
                    : 'Loading...',
                description: 'Thank you for joining and supporting our cause.',
              ),

              // Example other static banners
              buildBannerCard(
                title: 'New App Features',
                description:
                    'Version 2.1 comming soon with better performance, profile updates, and improved UI.',
              ),
              buildBannerCard(
                title: 'Volunteer Registration Open',
                description:
                    'We are looking for volunteers! Register now and help us organize camps.',
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
