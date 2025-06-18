
// widgets/blood_group_selector.dart
import 'package:flutter/material.dart';

class BloodGroupSelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const BloodGroupSelector({required this.selected, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    return Wrap(
      children: groups.map((g) {
        return ChoiceChip(
          label: Text(g),
          selected: selected == g,
          onSelected: (_) => onChanged(g),
        );
      }).toList(),
    );
  }
}
