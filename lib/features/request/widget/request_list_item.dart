// features/request/widgets/request_list_item.dart
import 'package:flutter/material.dart';

class RequestListItem extends StatelessWidget {
  const RequestListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text("Request from hospital XYZ"));
  }
}
