import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.volunteer_activism, color: Colors.redAccent),
            title: const Text('Donate'),
            subtitle: const Text('Support us with a financial donation'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to donation page
            },
          ),

          const Divider(),
           ListTile(
            leading: const Icon(Icons.help_outline,color: Colors.red,),
            title: const Text('Support & Feedback'),
            subtitle: const Text('Help Center / FAQ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to donation page
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('App information'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to about screen
            },
          ),
        ],
      ),
    );
  }
}
