// main.dart
import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart'; // or onboarding_screen.dart

void main() {
  runApp(TeamBuilderApp());
}

class TeamBuilderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamBuilder+',
      debugShowCheckedModeBanner: false,
      home: SignInScreen(), // Change to OnboardingScreen if needed
    );
  }
}
