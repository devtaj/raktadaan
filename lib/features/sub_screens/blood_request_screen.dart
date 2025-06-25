import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart'; // Make sure you import your auth service

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _caseController = TextEditingController();

  String? _selectedBloodGroup;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = AuthService().currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to submit a request.')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('bloodrequest').add({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'hospital': _hospitalController.text,
          'qty': _qtyController.text,
          'case': _caseController.text,
          'bloodGroup': _selectedBloodGroup,
          'timestamp': FieldValue.serverTimestamp(),
          'postedByUserId': user.uid, // ✅ This is required
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blood request submitted successfully!')),
        );

        // Clear form after submission
        _formKey.currentState!.reset();
        _nameController.clear();
        _phoneController.clear();
        _locationController.clear();
        _hospitalController.clear();
        _qtyController.clear();
        _caseController.clear();
        setState(() {
          _selectedBloodGroup = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _hospitalController.dispose();
    _qtyController.dispose();
    _caseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Not Logged In'),
            content: const Text('You\'re not logged in. Please go to login.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        );
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _hospitalController,
                decoration: const InputDecoration(labelText: 'Hospital Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter hospital name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Required Qty (units)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter required quantity' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _caseController,
                decoration: const InputDecoration(labelText: 'Case / Reason'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter case or reason' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group'),
                items: _bloodGroups
                    .map((group) => DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        ))
                    .toList(),
                validator: (value) =>
                    value == null ? 'Please select blood group' : null,
                onChanged: (value) {
                  setState(() {
                    _selectedBloodGroup = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.bloodtype),
                label: const Text('Submit Request'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _submitRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
