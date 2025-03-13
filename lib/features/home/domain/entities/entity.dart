import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SearchedUser {
  final String name;
  final String profilePic;
  final String major;
  SearchedUser({
    required this.name,
    required this.profilePic,
    required this.major,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'major': major,
    };
  }

  factory SearchedUser.fromMap(Map<String, dynamic> map) {
    return SearchedUser(
      name: map['name'] as String,
      profilePic: map['photoUrl'] as String,
      major: map['major'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SearchedUser.fromJson(String source) =>
      SearchedUser.fromMap(json.decode(source) as Map<String, dynamic>);
}
