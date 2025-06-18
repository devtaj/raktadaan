import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyNumberList extends StatefulWidget {
  const EmergencyNumberList({super.key});

  @override
  State<EmergencyNumberList> createState() => _EmergencyNumberListState();
}

class _EmergencyNumberListState extends State<EmergencyNumberList> {
  Future<void> _openDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Numbers')),
      body: ListView(
        children: [
          Card(
            elevation: 5,
            child: ListTile(
              title: const Text("Police"),
              subtitle: const Text("Dial 100"),
              leading: const Icon(Icons.local_police),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.red),
                onPressed: () => _openDialer('100'),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: ListTile(
              title: const Text("Ambulance"),
              subtitle: const Text("Dial 102"),
              leading: const Icon(Icons.local_hospital),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.red),
                onPressed: () => _openDialer('102'),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: ListTile(
              title: const Text("Fire Brigade"),
              subtitle: const Text("Dial 101"),
              leading: const Icon(Icons.fire_extinguisher),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.red),
                onPressed: () => _openDialer('101'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
