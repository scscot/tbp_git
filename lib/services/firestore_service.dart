// FINAL PATCHED: firestore_service.dart — Uses Cloud Function for user profile lookup

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class FirestoreService {
  final String cloudFunctionUrl =
      'https://us-central1-teambuilder-plus-fe74d.cloudfunctions.net/getUserProfileByEmail';

  Future<UserModel?> getUserProfileByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse(cloudFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-user-email': email,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        print(
            '❌ Failed to fetch user profile: ${response.statusCode} — ${response.body}');
        return null;
      }
    } catch (e) {
      print('🔥 Error in getUserProfileByEmail: $e');
      return null;
    }
  }
}