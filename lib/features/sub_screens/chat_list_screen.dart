import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raktadan/core/services/auth_service.dart';
import 'package:raktadan/features/sub_screens/simple_chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No chats yet\nStart a conversation!'),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;
              final participants = List<String>.from(data['participants'] ?? []);
              final otherUserId = participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('donors')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  String otherUserName = 'Loading...';
                  
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final data = userSnapshot.data!.data() as Map<String, dynamic>?;
                    otherUserName = data?['name']?.toString() ?? 'Unknown User';
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        otherUserName != 'Loading...' && otherUserName.isNotEmpty
                            ? otherUserName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(otherUserName),
                    subtitle: Text(
                      data['lastMessage'] ?? 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SimpleChatScreen(
                            chatId: chat.id,
                            otherUserName: otherUserName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
          DefaultTabController.of(context)?.animateTo(2);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }
}