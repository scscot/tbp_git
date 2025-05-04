import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teambuild/services/auth_service.dart';
import 'package:teambuild/services/firestore_service.dart';

class NewRegistrationScreen extends StatefulWidget {
  final AuthService authService;
  final FirestoreService firestoreService;

  const NewRegistrationScreen({
    super.key,
    required this.authService,
    required this.firestoreService,
  });

  @override
  State<NewRegistrationScreen> createState() => _NewRegistrationScreenState();
}

class _NewRegistrationScreenState extends State<NewRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final city = _cityController.text.trim();
      final state = _stateController.text.trim();
      final country = _countryController.text.trim();
      final referredBy = _referralCodeController.text.trim();

      try {
        final result = await widget.authService.createUserWithEmail(email, password, fullName);
        final userId = result['uid']!;
        final idToken = result['idToken']!;

        final userData = {
          'fullName': fullName,
          'email': email,
          'city': city,
          'state': state,
          'country': country,
          'referredBy': referredBy.isNotEmpty ? referredBy : null,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        };

        await widget.firestoreService.createUserProfile(
          idToken,
          userId,
          userData,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your full name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your password' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your city' : null,
              ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State/Province'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your state/province' : null,
              ),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your country' : null,
              ),
              TextFormField(
                controller: _referralCodeController,
                decoration: const InputDecoration(
                  labelText: 'Referral ID (optional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
