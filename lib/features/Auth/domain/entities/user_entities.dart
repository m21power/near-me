import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String password;
  final String name;
  final String? photoUrl;
  final String? backgroundUrl;
  final bool? isEmailVerified;
  final String? bio;
  final String gender;
  final String university;
  final String major;
  final String fcmToken;
  UserModel(
      {required this.id,
      required this.email,
      required this.university,
      required this.major,
      required this.name,
      required this.photoUrl,
      required this.backgroundUrl,
      required this.isEmailVerified,
      required this.password,
      required this.bio,
      required this.fcmToken,
      required this.gender});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl ?? '',
      'backgroundUrl': backgroundUrl ?? '',
      'isEmailVerified': isEmailVerified,
      'password': password,
      'bio': bio ?? '',
      'gender': gender,
      'university': university,
      'major': major,
      'fcmToken': fcmToken
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        id: map['id'] ?? "",
        email: map['email'] as String,
        name: map['name'] as String,
        photoUrl: map['photoUrl'] ?? "",
        backgroundUrl: map['backgroundUrl'] ?? "",
        isEmailVerified: map['isEmailVerified'] as bool,
        password: map['password'] ?? "",
        bio: map['bio'] ?? "",
        gender: map['gender'] as String,
        university: map['university'] ?? "",
        fcmToken: map['fcmToken'] ?? '',
        major: map['major'] ?? "");
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
