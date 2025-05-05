// FINAL PATCHED: auth_service.dart — Fully preserved version (170+ lines) with createUserWithEmail()

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String apiKey = dotenv.env['GOOGLE_API_KEY']!;
  final String projectId = 'teambuilder-plus-fe74d';

  final session = SessionManager.instance;

  Future<String?> _exchangeRefreshToken(String refreshToken) async {
    final url = Uri.parse('https://securetoken.googleapis.com/v1/token?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'grant_type=refresh_token&refresh_token=$refreshToken',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['access_token'] != null) {
      return data['access_token'];
    } else {
      print('❌ Failed to exchange refreshToken: ${data['error']}');
      return null;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final accessToken = await _exchangeRefreshToken(body['refreshToken']);
      print('🪪 Firebase ID Token: ${body['idToken']}');
      session.saveSession(
        user: UserModel(
          uid: body['localId'],
          email: body['email'] ?? email,
          fullName: body['displayName'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
        ),
        idToken: body['idToken'],
        accessToken: accessToken ?? '',
      );
    } else {
      print('❌ Login failed: ${body['error']}');
      throw Exception(body['error']?['message'] ?? 'Login failed');
    }
  }

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['localId'] != null) {
      final accessToken = await _exchangeRefreshToken(data['refreshToken']);
      print('🪪 Firebase ID Token: ${data['idToken']}');
      session.saveSession(
        user: UserModel(
          uid: data['localId'],
          email: data['email'] ?? email,
          fullName: data['displayName'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
        ),
        idToken: data['idToken'],
        accessToken: accessToken ?? '',
      );

      final userProfileMap = await FirestoreService().getUserProfileByEmail(data['email']);
      if (userProfileMap != null) {
        return UserModel.fromJson(userProfileMap);
      }
      return null;
    } else {
      final error = data['error']?['message'] ?? 'Unknown error';
      throw Exception('Login failed: $error');
    }
  }

  Future<Map<String, String>> createUserWithEmail(
    String email,
    String password,
    String fullName, [
    String? referredBy,
  ]) async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final accessToken = await _exchangeRefreshToken(body['refreshToken']);
      print('🪪 Firebase ID Token: ${body['idToken']}');
      session.saveSession(
        user: UserModel(
          uid: body['localId'],
          email: email,
          fullName: fullName,
          createdAt: DateTime.now().toIso8601String(),
        ),
        idToken: body['idToken'],
        accessToken: accessToken ?? '',
      );

      print('✅ Account created. Token: ${body['idToken']}, UserID: ${body['localId']}');

      return {
        'uid': body['localId'],
        'idToken': body['idToken'],
      };
    } else {
      print('❌ Account creation failed: ${body['error']}');
      throw Exception(body['error']?['message'] ?? 'Account creation failed');
    }
  }

  String? getIdToken() => session.idToken;
  String? getAccessToken() => session.accessToken;
  String? getCurrentUserEmail() => session.currentUser?.email;
  String? getCurrentUserId() => session.currentUser?.uid;
  String? getCurrentUserName() => session.currentUser?.fullName;

  Future<void> signOut() async {
    session.clear();
  }

  bool isSignedIn() => session.currentUser != null && session.currentUser!.uid.isNotEmpty;

  String _generateReferralCode(String email) {
    final hash = email.hashCode.toRadixString(36).toUpperCase();
    return hash.substring(0, hash.length > 6 ? 6 : hash.length);
  }
}
