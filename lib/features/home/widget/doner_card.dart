// features/home/widgets/donor_card.dart
import 'package:flutter/material.dart';

class DonorCard extends StatelessWidget {
  const DonorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text("Donor Name")),
    );
  }
}
