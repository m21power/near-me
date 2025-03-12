// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserLocEntity {
  String userId;
  String name;
  String email;
  String photoUrl;
  double latitude;
  double longitude;
  String university;
  String major;
  String backgroundUrl;
  bool isEmailVerified;
  String password;
  String bio;
  String gender;

  UserLocEntity(
      {required this.userId,
      required this.name,
      required this.email,
      required this.photoUrl,
      required this.latitude,
      required this.longitude,
      required this.university,
      required this.major,
      required this.backgroundUrl,
      required this.isEmailVerified,
      required this.password,
      required this.bio,
      required this.gender});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'university': university,
      'major': major,
      'backgroundUrl': backgroundUrl,
      'isEmailVerified': isEmailVerified,
      'password': password,
      'bio': bio,
      'gender': gender,
    };
  }

  factory UserLocEntity.fromMap(Map<String, dynamic> map) {
    return UserLocEntity(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      university: map['university'] ?? '',
      major: map['major'] ?? '',
      backgroundUrl: map['backgroundUrl'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? true,
      password: map['password'] ?? '',
      bio: map['bio'] ?? '',
      gender: map['gender'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserLocEntity.fromJson(String source) =>
      UserLocEntity.fromMap(json.decode(source));
}
