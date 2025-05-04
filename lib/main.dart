// PATCHED: main.dart (removes outdated authService param for ProfileScreen)

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen_v2.dart';
import 'screens/profile_screen.dart';
import 'services/session_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamBuild+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: EntryPoint(),
    );
  }
}

class EntryPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = SessionManager.instance.currentUser;
    if (user == null) {
      return const LoginScreen();
    } else if ((user.fullName ?? '').isEmpty) {
      // Placeholder for profile completion screen if needed
      return const ProfileScreen();
    } else {
      return const DashboardScreenV2();
    }
  }
}
