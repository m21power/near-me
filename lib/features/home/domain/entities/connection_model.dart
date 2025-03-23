// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ConnectionModel {
  final String name;
  final String profilePic;
  final String id;
  final String gender;
  final bool isOnline;
  final String lastSeen;

  ConnectionModel(
      {required this.name,
      required this.profilePic,
      required this.id,
      required this.gender,
      required this.isOnline,
      required this.lastSeen});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'id': id,
      'gender': gender,
      'isOnline': isOnline == true ? 1 : 0,
      'lastSeen': lastSeen,
    };
  }

  factory ConnectionModel.fromMap(Map<String, dynamic> map) {
    return ConnectionModel(
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      id: map['id'] as String,
      gender: map['gender'] as String,
      isOnline: map['isOnline'] == 1 ? true : false,
      lastSeen: map['lastSeen'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectionModel.fromJson(String source) =>
      ConnectionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  ConnectionModel copyWith({
    String? name,
    String? profilePic,
    String? id,
    String? gender,
    bool? isOnline,
    String? lastSeen,
  }) {
    return ConnectionModel(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      id: id ?? this.id,
      gender: gender ?? this.gender,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
