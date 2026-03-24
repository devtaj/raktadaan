import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:raktadan/core/services/auth_service.dart';
import 'package:raktadan/core/services/blood_request_service.dart';
import 'package:raktadan/core/utils/error_handler.dart';
import 'package:raktadan/core/utils/validators.dart';

import 'package:raktadan/features/sub_screens/blood_request_list.dart';
import 'package:raktadan/features/sub_screens/doner_list.dart';
import 'package:raktadan/features/sub_screens/main_screen.dart';
import 'package:raktadan/features/sub_screens/chat_list_screen.dart';
import 'package:raktadan/features/sub_screens/simple_chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final BloodRequestService _requestService = BloodRequestService();

  List<Widget> get _screens => [
    MainScreen(onNavigateToTab: (index) {
      setState(() {
        _selectedIndex = index;
      });
    }),
    const BloodRequestList(),
    const DonorListScreen(),
    const ChatListScreen(),
  ];

  void _logout(BuildContext context) async {
    try {
      await AuthService().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Logout failed: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Raktadan"),
        actions: [
          if (userId.isNotEmpty)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('request_notifications')
                  .where('receiverId', isEqualTo: userId)
                  .where('seen', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                int unseenCount = snapshot.data?.docs.length ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _openNotificationsDrawer(context, userId, _requestService);
                      },
                    ),
                    if (unseenCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unseenCount > 99 ? '99+' : unseenCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () async {
              final result = await showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(80, 80, 0, 0),
                items: [
                  PopupMenuItem(
                    value: 'profile',
                    child: const Text('Profile'),
                  ),
                  PopupMenuItem(
                    value: 'settings', 
                    child: const Text('Settings'),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: const Text('Log Out'),
                  ),
                ],
              );
              
              if (result != null) {
                switch (result) {
                  case 'profile':
                    Navigator.pushNamed(context, '/profile');
                    break;
                  case 'settings':
                    Navigator.pushNamed(context, '/settings');
                    break;
                  case 'logout':
                    _logout(context);
                    break;
                }
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.blue,
        activeColor: Colors.white,
        color: Colors.white,
        initialActiveIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.bloodtype, title: 'Requests'),
          TabItem(icon: Icons.favorite, title: 'Donors'),
          TabItem(icon: Icons.chat, title: 'Chats'),
        ],
      ),
    );
  }
}

String _generateChatId(String userId1, String userId2) {
  final sortedIds = [userId1, userId2]..sort();
  return '${sortedIds[0]}_${sortedIds[1]}';
}

void _openNotificationsDrawer(BuildContext context, String userId, BloodRequestService requestService) {
  // Mark notifications as seen when drawer opens
  requestService.markNotificationsAsSeen(userId);
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DefaultTabController(
        length: 2,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Notifications",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('request_notifications')
                        .where('receiverId', isEqualTo: userId)
                        .where('status', isEqualTo: 'pending')
                        .where('seen', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Requests'),
                            if (count > 0) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .where('requesterId', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      int totalUnread = 0;
                      if (snapshot.hasData) {
                        for (final doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          totalUnread += (data['unreadCount_$userId'] as int?) ?? 0;
                        }
                      }
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Chats'),
                            if (totalUnread > 0) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  totalUnread.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRequestsTab(userId, requestService),
                    _buildChatsTab(userId, requestService),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildRequestsTab(String userId, BloodRequestService requestService) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('request_notifications')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data?.docs ?? [];

      if (docs.isEmpty) {
        return const Center(child: Text("No pending requests"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final requestData = doc.data() as Map<String, dynamic>;
          final donorId = requestData['senderId'] ?? '';
          final donorName = requestData['senderName'] ?? 'Unknown';
          final donorBloodGroup = requestData['senderBloodGroup'] ?? 'N/A';

          return Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.red),
              title: Text(donorName),
              subtitle: Text('Blood Group: $donorBloodGroup'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      try {
                        await requestService.acceptRequest(
                          requestId: doc.id,
                          userId: userId,
                          donorId: donorId,
                          requestData: requestData,
                        );
                        if (context.mounted) {
                          ErrorHandler.showSuccess(context, 'Request accepted');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ErrorHandler.showError(context, 'Failed to accept');
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      try {
                        await requestService.rejectRequest(doc.id);
                        if (context.mounted) {
                          ErrorHandler.showSuccess(context, 'Request rejected');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ErrorHandler.showError(context, 'Failed to reject');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildChatsTab(String userId, BloodRequestService requestService) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('chats')
        .where('requesterId', isEqualTo: userId)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data?.docs ?? [];

      if (docs.isEmpty) {
        return const Center(child: Text("No active chats"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final data = doc.data() as Map<String, dynamic>;
          final donorName = data['donorName'] ?? 'Unknown';
          final lastMessage = data['lastMessage'] ?? 'No messages';

          final unreadCount = (data['unreadCount_$userId'] as int?) ?? 0;
          
          return Card(
            child: ListTile(
              leading: const Icon(Icons.chat, color: Colors.blue),
              title: Text(donorName),
              subtitle: Text(lastMessage),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              onTap: () {
                final chatId = _generateChatId(data['donorId'] ?? '', userId);
                // Mark messages as seen when opening chat
                requestService.markMessagesAsSeen(chatId, userId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimpleChatScreen(
                      chatId: chatId,
                      otherUserName: donorName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}
