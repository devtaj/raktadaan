import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: kIsWeb
            ? const FirebaseOptions(
                apiKey: "AIzaSyDzQ5mNqMJH4UEI-Bo6qcVxjy8tiObCGRs",
                authDomain: "raktadan-69da2.firebaseapp.com", // add authDomain for web
                projectId: "raktadan-69da2",
                messagingSenderId: "129174984799",
                appId: "1:129174984799:android:f7cd6cafd320df028323ea",
                storageBucket: "raktadan-69da2.appspot.com", // add if you have
                
              )
            : null, // no options needed for mobile
      );
    }
    print('Firebase initialized successfully!');
  } catch (e) {
    print('Firebase initialization failed: $e');
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
