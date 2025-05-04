// PATCHED: onboarding_screen.dart (removes outdated authService param)

import 'package:flutter/material.dart';
import 'package:teambuild/screens/login_screen.dart';
import 'package:teambuild/screens/new_registration_screen.dart';
import 'package:teambuild/services/firestore_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final FirestoreService firestoreService;

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to TeamBuild+', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ));
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => NewRegistrationScreen(
                    firestoreService: firestoreService,
                  ),
                ));
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
