import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SearchedUser {
  final String name;
  final String profilePic;
  final String major;
  final String id;
  final String gender;
  SearchedUser(
      {required this.name,
      required this.profilePic,
      required this.major,
      required this.gender,
      required this.id});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'major': major,
      'gender': gender,
      'id': id
    };
  }

  factory SearchedUser.fromMap(Map<String, dynamic> map) {
    return SearchedUser(
        name: map['name'] ?? "",
        profilePic: map['photoUrl'] ?? '',
        major: map['major'] ?? '',
        gender: map['gender'] ?? '',
        id: map['id']);
  }

  String toJson() => json.encode(toMap());

  factory SearchedUser.fromJson(String source) =>
      SearchedUser.fromMap(json.decode(source) as Map<String, dynamic>);
}
