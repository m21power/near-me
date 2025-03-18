import 'dart:convert';

class PostModel {
  final int postId;
  final String userId;
  final String postUrl;
  int likeCount;
  final String gender;
  final String name;
  final String profilePic;
  final DateTime createdAt;
  PostModel({
    required this.postId,
    required this.userId,
    required this.postUrl,
    required this.likeCount,
    required this.name,
    required this.gender,
    required this.profilePic,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postId': postId,
      'userId': userId,
      'postUrl': postUrl,
      'likeCount': likeCount,
      'name': name,
      'gender': gender,
      'profilePic': profilePic,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['id'] as int,
      userId: map['userId'] as String,
      postUrl: map['postUrl'] as String,
      likeCount: map['likeCount'] as int,
      name: map['name'] as String,
      gender: map['gender'] as String,
      profilePic: map['profilePic'],
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
