import 'package:firebase_auth_rest/firebase_auth_rest.dart';

void main() {
  final auth = FirebaseAuthRest(apiKey: 'TEST_KEY');
  print(auth.runtimeType);
}
