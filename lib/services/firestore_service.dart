// FINAL PATCHED: firestore_service.dart — includes createUserProfile() for registration

import 'dart:convert';
import 'package:http/http.dart' as http;

class FirestoreService {
  final String projectId = 'teambuilder-plus-fe74d';

  Future<Map<String, dynamic>?> getUserProfileByEmail(String email) async {
    final query = Uri.encodeComponent("email = '$email'");
    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents:runQuery',
    );

    final body = {
      "structuredQuery": {
        "from": [{"collectionId": "users"}],
        "where": {
          "fieldFilter": {
            "field": {"fieldPath": "email"},
            "op": "EQUAL",
            "value": {"stringValue": email},
          }
        },
        "limit": 1
      }
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final results = json.decode(response.body);
      final doc = results.firstWhere((r) => r['document'] != null, orElse: () => null);
      if (doc != null) {
        final data = doc['document']['fields'] as Map<String, dynamic>;
        final id = doc['document']['name'].split('/').last;
        return {"id": id, ..._flattenFields(data)};
      }
    }
    return null;
  }

  Map<String, dynamic> _flattenFields(Map<String, dynamic> fields) {
    final result = <String, dynamic>{};
    fields.forEach((key, value) {
      result[key] = value.values.first;
    });
    return result;
  }

  Future<void> createUserProfile(
    String idToken,
    String userId,
    Map<String, dynamic> userData,
  ) async {
    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users?documentId=$userId',
    );

    final body = {
      "fields": userData.map((key, value) => MapEntry(
            key,
            {"stringValue": value.toString()},
          ))
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create user profile: ${response.body}');
    }
  }
}
