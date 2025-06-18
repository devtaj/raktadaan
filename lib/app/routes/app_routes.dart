// app/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:raktadan/features/sub_screens/emergency_number_list.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart'; // ✅ Add this import
import '../../features/home/screens/home_screen.dart';

class AppRoutes {
  static const initial = '/home';

  static final routes = <String, WidgetBuilder>{
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(), // ✅ Add this line
    '/home': (_) => const HomeScreen(),
    '/emergencyNumbers': (_) => const EmergencyNumberList(),
  };
}
