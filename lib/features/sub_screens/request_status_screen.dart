import 'package:flutter/material.dart';
import 'package:raktadan/core/services/blood_request_status_service.dart';

class RequestStatusScreen extends StatelessWidget {
  const RequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Status')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: BloodRequestStatusService.fetchRequestStatus('GlrWutzV42tm6dsnvDVN'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('No data found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: data.entries.map((entry) {
              return Card(
                child: ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value.toString()),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}