import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raktadan/core/services/auth_service.dart';
import 'package:raktadan/features/sub_screens/simple_chat_screen.dart';

class DonorChatsScreen extends StatelessWidget {
  const DonorChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('donorId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading chats'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No donation chats available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final chatId = docs[index].id;
              final lastMessage = data['lastMessage'] ?? 'No messages yet';

              return Card(
                key: ValueKey(chatId),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text('Blood Request Chat'),
                  subtitle: Text(lastMessage),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SimpleChatScreen(
                          chatId: chatId,
                          otherUserName: 'Requester',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}