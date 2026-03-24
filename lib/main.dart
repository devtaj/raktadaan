import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'core/config/firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: kIsWeb ? FirebaseConfig.webOptions : null,
      );
    }
    debugPrint('Firebase initialized successfully!');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const RaktadanApp());
}

class RaktadanApp extends StatelessWidget {
  const RaktadanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raktadan',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.routes,
    );
  }
}
