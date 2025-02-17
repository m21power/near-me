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
  final double? lat;
  final double? lon;
  final bool? getNearby;
  final bool? userStatusVisibility;
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.backgroundUrl,
    required this.isEmailVerified,
    required this.password,
    required this.bio,
    required this.lat,
    required this.userStatusVisibility,
    required this.lon,
    required this.getNearby,
  });

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
      'lat': lat ?? 0.0,
      'lon': lon ?? 0.0,
      'getNearby': getNearby,
      'userStatusVisibility': userStatusVisibility ?? true,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String,
      backgroundUrl: map['backgroundUrl'] as String,
      isEmailVerified: map['isEmailVerified'] as bool,
      password: map['password'] as String,
      bio: map['bio'] as String,
      lat: map['lat'] as double,
      lon: map['lon'] as double,
      getNearby: map['getNearby'] as bool,
      userStatusVisibility: map['userStatusVisibility'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
