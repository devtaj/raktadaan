import 'package:flutter/material.dart';
import 'package:raktadan/core/services/auth_service.dart';
import 'package:raktadan/core/services/donation_chat_service.dart';
import 'package:raktadan/features/profile/screens/progress_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUser?.uid ?? '';
    final chatService = DonationChatService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Donation Chats')),
      body: FutureBuilder(
        future: chatService.getUserChats(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active donation chats'));
          }

          final chats = snapshot.data!;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;
              final isReceiver = data['receiverId'] == currentUserId;
              
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(data['status'] ?? 'pending'),
                    child: Text(
                      data['donorBloodGroup'] ?? 'N/A',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(data['donorName'] ?? 'Unknown'),
                  subtitle: Text(
                    '${isReceiver ? 'Receiving from' : 'Donating to'} • ${_formatStatus(data['status'] ?? 'pending')}',
                  ),
                  trailing: const Icon(Icons.chat),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonationChatScreen(
                          requestId: chat.id,
                          donorName: data['donorName'] ?? 'Unknown',
                          donorBloodGroup: data['donorBloodGroup'] ?? 'N/A',
                          receiverId: data['receiverId'] ?? '',
                          donorId: data['donorId'] ?? '',
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

  String _formatStatus(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'on_the_way': return 'On the Way';
      case 'donating': return 'Donating';
      case 'fulfilled': return 'Fulfilled';
      case 'cancelled': return 'Cancelled';
      default: return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'fulfilled': return Colors.green;
      case 'donating': return Colors.orange;
      case 'on_the_way': return Colors.blue;
      case 'cancelled': return Colors.grey;
      default: return Colors.red;
    }
  }
}