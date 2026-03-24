import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raktadan/core/services/auth_service.dart';
import 'package:raktadan/core/services/donation_chat_service.dart';

class DonationChatScreen extends StatefulWidget {
  final String requestId;
  final String donorName;
  final String donorBloodGroup;
  final String receiverId;
  final String donorId;

  const DonationChatScreen({
    super.key,
    required this.requestId,
    required this.donorName,
    required this.donorBloodGroup,
    required this.receiverId,
    required this.donorId,
  });

  @override
  State<DonationChatScreen> createState() => _DonationChatScreenState();
}

class _DonationChatScreenState extends State<DonationChatScreen> {

  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = AuthService().currentUser?.uid ?? '';
  final DonationChatService _chatService = DonationChatService();

  String _formatStatus(String status) {
    switch (status) {
      case 'pending': return "Pending";
      case 'on_the_way': return "On the Way";
      case 'donating': return "Donating";
      case 'fulfilled': return "Fulfilled";
      case 'cancelled': return "Cancelled";
      default: return "Unknown";
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    await _chatService.updateStatus(widget.requestId, _formatStatus(newStatus), currentUserId);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    await _chatService.sendMessage(widget.requestId, _messageController.text.trim(), currentUserId);
    _messageController.clear();
  }


  @override
  Widget build(BuildContext context) {
    // Only allow donor or receiver to access chat
    if (currentUserId != widget.donorId && currentUserId != widget.receiverId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have permission to view this chat'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.donorName} (${widget.donorBloodGroup})'),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _chatService.getChatStatus(widget.requestId),
            builder: (context, snapshot) {
              final status = snapshot.data?.get('status') ?? 'pending';
              return Chip(
                label: Text(_formatStatus(status)),
                backgroundColor: _getStatusColor(status),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildStatusButtons(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getChatMessages(widget.requestId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == currentUserId;
                    final isSystem = message['senderId'] == 'system';

                    return _buildMessageBubble(
                      message['text'],
                      isMe,
                      isSystem,
                      message['timestamp']?.toDate(),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildStatusButtons() {
    // Only donor can update status
    if (currentUserId != widget.donorId) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _chatService.getChatStatus(widget.requestId),
      builder: (context, snapshot) {
        final status = snapshot.data?.get('status') ?? 'pending';
        return Container(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 4,
            children: [
              _statusButton('pending', Colors.red, status),
              _statusButton('on_the_way', Colors.blue, status),
              _statusButton('donating', Colors.orange, status),
              _statusButton('fulfilled', Colors.green, status),
              _statusButton('cancelled', Colors.grey, status),
            ],
          ),
        );
      },
    );
  }

  Widget _statusButton(String statusValue, Color color, String currentStatus) {
    return ElevatedButton(
      onPressed: currentStatus != statusValue ? () => _updateStatus(statusValue) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: currentStatus == statusValue ? color : Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(
        _formatStatus(statusValue),
        style: TextStyle(
          fontSize: 12,
          color: currentStatus == statusValue ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, bool isSystem, DateTime? timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isSystem
            ? MainAxisAlignment.center
            : isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSystem
                  ? Colors.grey[200]
                  : isMe
                      ? Colors.blue
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe && !isSystem ? Colors.white : Colors.black,
                fontStyle: isSystem ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
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
