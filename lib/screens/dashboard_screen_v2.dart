// PATCHED: dashboard_screen_v2.dart (removes outdated authService param)

import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import '../models/user_model.dart';
import 'profile_screen.dart';
import 'downline_team_screen.dart';

class DashboardScreenV2 extends StatelessWidget {
  const DashboardScreenV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.fullName ?? 'User'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: const Text('View Profile'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DownlineTeamScreen(),
                  ),
                );
              },
              child: const Text('View Downline Team'),
            ),
          ],
        ),
      ),
    );
  }
}