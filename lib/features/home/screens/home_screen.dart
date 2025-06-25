// features/home/screens/home_screen.dart
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:raktadan/core/services/auth_service.dart';
import 'package:raktadan/features/sub_screens/blood_request_list.dart';
// import 'package:raktadan/features/sub_screens/blood_request_screen.dart';
import 'package:raktadan/features/sub_screens/doner_list.dart';
import 'package:raktadan/features/sub_screens/main_screen.dart';

// import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MainScreen(),
    const BloodRequestList(),
    const DonorListScreen(),
  ];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Raktadan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(80, 80, 0, 0),
                items: [
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: const Text('Profile'),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                      child: const Text('Notification'),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        _logout(context);
                      },
                      child: const Text('Log Out'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
  backgroundColor: Colors.red,
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
    TabItem(icon: Icons.bloodtype, title: 'Blood Request'),
    TabItem(icon: Icons.favorite, title: 'Donor List'),
  ],
),

    );
  }
}
