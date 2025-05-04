// PATCHED: user_model.dart — added 'level' field

class UserModel {
  final String uid;
  final String email;
  final String? fullName;
  final dynamic createdAt;
  final String? photoUrl;
  final String? referredBy;
  final String? referredByName;
  final String? level; // ✅ ADDED

  UserModel({
    required this.uid,
    required this.email,
    this.fullName,
    this.createdAt,
    this.photoUrl,
    this.referredBy,
    this.referredByName,
    this.level, // ✅ ADDED
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      createdAt: json['createdAt'],
      photoUrl: json['photoUrl'],
      referredBy: json['referredBy'],
      referredByName: json['referredByName'],
      level: json['level'], // ✅ ADDED
    );
  }

  static UserModel fromFirestore(Map<String, dynamic> doc) {
    final fields = doc['fields'] ?? {};

    return UserModel(
      uid: fields['uid']?['stringValue'] ?? '',
      email: fields['email']?['stringValue'] ?? '',
      fullName: fields['fullName']?['stringValue'],
      createdAt: fields['createdAt']?['stringValue'],
      photoUrl: fields['photoUrl']?['stringValue'],
      referredBy: fields['referredBy']?['stringValue'],
      referredByName: fields['referredByName']?['stringValue'],
      level: fields['level']?['stringValue'], // ✅ ADDED
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt,
      'photoUrl': photoUrl,
      'referredBy': referredBy,
      'referredByName': referredByName,
      'level': level, // ✅ ADDED
    };
  }
}
