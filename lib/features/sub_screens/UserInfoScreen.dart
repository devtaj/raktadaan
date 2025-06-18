import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class UserInfoScreen extends StatelessWidget {
  final String userId;
  final String name;
  final String bloodGroup;
  final DateTime registrationDate;

  const UserInfoScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.bloodGroup,
    required this.registrationDate,
  });

  void _shareCard(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(registrationDate);

    final String content = '''
🩸 Blood Donation Card 🩸

Name: $name
Blood Group: $bloodGroup
User ID: $userId
Registered on: $formattedDate

Be a Hero. Donate Blood. ❤️
''';
    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(registrationDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Donation Card')),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400, // Max width for large screens (tablet, web)
            ),
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.all(16), // Margin for spacing on all sides
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bloodtype, size: 80, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Blood Group: $bloodGroup',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 30, thickness: 1),
                    Text(
                      'User ID:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      userId,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Registered on: $formattedDate',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    QrImageView(
                      data: 'User: $name\nBlood Group: $bloodGroup\nID: $userId',
                      version: QrVersions.auto,
                      size: 120,
                      gapless: false,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Share Card'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _shareCard(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
