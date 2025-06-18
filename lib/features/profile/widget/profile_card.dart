// features/profile/widgets/profile_card.dart
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text("User Name")),
    );
  }
}
