// features/request/screens/request_form_screen.dart
import 'package:flutter/material.dart';

class RequestFormScreen extends StatelessWidget {
  const RequestFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Blood")),
      body: Center(child: Text("Form to request blood")),
    );
  }
}