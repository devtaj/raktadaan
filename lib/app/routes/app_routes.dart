// app/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:raktadan/features/profile/screens/profile_screen.dart';
import 'package:raktadan/features/sub_screens/add_blood_donation_events.dart';
import 'package:raktadan/features/sub_screens/blood_request_screen.dart';
import 'package:raktadan/features/sub_screens/event_screen.dart';
import 'package:raktadan/features/sub_screens/blood_banks.dart';
import 'package:raktadan/features/sub_screens/emergency_number_list.dart';
import 'package:raktadan/features/sub_screens/notification_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart'; 
import '../../features/home/screens/home_screen.dart';

class AppRoutes {
  static const initial = '/home';

  static final routes = <String, WidgetBuilder>{
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(), 
    '/home': (_) => const HomeScreen(),
    '/emergencyNumbers': (_) => const EmergencyNumberList(),
    '/bloodBanks': (_) => const BloodBanksScreen(), 
    '/addEvent': (_) => const EventListScreen(), 
    '/addBloodDonationEvent': (_) => const AddBloodDonationEventScreen(),
    '/profile':(_)=> const ProfileScreen(),
    '/bloodRequest': (_) => const BloodRequestScreen(),
    '/notifications': (_) => const NotificationScreen(),

    
    
  };
}
