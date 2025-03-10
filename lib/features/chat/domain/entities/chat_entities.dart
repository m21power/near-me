// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class BubbleModel {
  final String message;
  final Timestamp timestamp;
  final bool seen;
  final String senderId;
  final DocumentSnapshot? documentSnapshot;
  BubbleModel(
      {required this.message,
      required this.seen,
      required this.timestamp,
      required this.senderId,
      required this.documentSnapshot});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'senderId': senderId,
      'timestamp': timestamp.toDate().toIso8601String(),
      'seen': seen,
    };
  }

  // factory BubbleModel.fromMap(Map<String, dynamic> map) {
  //   return BubbleModel(
  //     message: map['message'] as String,
  //     timestamp: map['timestamp'] as Timestamp, // Directly use it
  //     seen: map['seen'] as bool,
  //     senderId: map['senderId'] as String,
  //   );
  factory BubbleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BubbleModel(
      message: data['message'] as String,
      senderId: data['senderId'] as String,
      timestamp: data['timestamp'] as Timestamp,
      seen: data['seen'] as bool,
      documentSnapshot: doc, // Store the snapshot itself
    );
  }

  String toJson() => json.encode(toMap());

  // factory BubbleModel.fromJson(String source) =>
  //     BubbleModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ChatEntities {
  final String chatId;
  final String lastMessage;
  final Timestamp lastMessageTime;

  final String user1Id;
  final String user1Name;
  final String user1ProfilePic;
  final String user1Gender;

  final String user2Name;
  final String user2ProfilePic;
  final String user2Id;
  final String user2Gender;

  final int unreadCount;

  ChatEntities(
      {required this.chatId,
      required this.lastMessage,
      required this.lastMessageTime,
      required this.user1Id,
      required this.user2Name,
      required this.user2Id,
      required this.user2ProfilePic,
      required this.unreadCount,
      required this.user2Gender,
      required this.user1Gender,
      required this.user1Name,
      required this.user1ProfilePic});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatId': chatId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toDate().toIso8601String(),
      'user1Id': user1Id,
      'user1Gender': user1Gender,
      'user1Name': user1Name,
      'user1ProfilePic': user1ProfilePic,
      'user2Name': user2Name,
      'user2ProfilePic': user2ProfilePic,
      'user2Gender': user2Gender,
      'user2Id': user2Id,
      'unreadCount': unreadCount,
    };
  }

  factory ChatEntities.fromMap(Map<String, dynamic> map) {
    return ChatEntities(
      chatId: map['chatId'] as String,
      lastMessage: map['lastMessage'] as String,
      lastMessageTime: map['lastMessageTime'] as Timestamp,
      user1Id: map['user1Id'] as String,
      user1Gender: map['user1Gender'] as String,
      user1Name: map['user1Name'] as String,
      user1ProfilePic: map['user1ProfilePic'] as String,
      user2Gender: map['user2Gender'] as String,
      user2Name: map['user2Name'] as String,
      user2ProfilePic: map['user2ProfilePic'] as String,
      unreadCount: map['unreadCount'] as int,
      user2Id: map['user2Id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatEntities.fromJson(String source) =>
      ChatEntities.fromMap(json.decode(source) as Map<String, dynamic>);
}
