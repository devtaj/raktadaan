import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raktadan/core/services/auth_service.dart';

class DonorRequestScreen extends StatefulWidget {
  const DonorRequestScreen({super.key});

  @override
  State<DonorRequestScreen> createState() => _DonorRequestScreenState();
}

class _DonorRequestScreenState extends State<DonorRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedBloodGroup = 'A+';
  String _urgency = 'Normal';

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = AuthService().currentUser;
    if (currentUser == null) return;

    // Get donor info
    final donorDoc = await FirebaseFirestore.instance
        .collection('donors')
        .doc(currentUser.uid)
        .get();

    if (!donorDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donor profile not found')),
      );
      return;
    }

    final donorData = donorDoc.data()!;

    // Create blood request
    await FirebaseFirestore.instance.collection('bloodrequest').add({
      'donorId': currentUser.uid,
      'donorName': donorData['name'],
      'donorBloodGroup': donorData['bloodGroup'],
      'donorLocation': donorData['location'],
      'donorPhone': donorData['phoneNumber'],
      'requestedBloodGroup': _selectedBloodGroup,
      'message': _messageController.text.trim(),
      'urgency': _urgency,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blood request submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group Needed'),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((group) => DropdownMenuItem(value: group, child: Text(group)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _urgency,
                decoration: const InputDecoration(labelText: 'Urgency'),
                items: ['Normal', 'Urgent', 'Emergency']
                    .map((urgency) => DropdownMenuItem(value: urgency, child: Text(urgency)))
                    .toList(),
                onChanged: (value) => setState(() => _urgency = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitRequest,
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}