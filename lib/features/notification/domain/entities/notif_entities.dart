// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final bool accepted;
  final String from;
  final String to;
  final String title;
  final String body;
  final Timestamp timestamp;
  final String profilePic;
  final String name;
  final String status;
  final String fromGender;
  final String major;

  NotificationModel(
      {required this.accepted,
      required this.from,
      required this.to,
      required this.title,
      required this.body,
      required this.timestamp,
      required this.profilePic,
      required this.name,
      required this.status,
      required this.major,
      required this.fromGender});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accepted': accepted,
      'from': from,
      'to': to,
      'title': title,
      'body': body,
      'timestamp': timestamp.toDate().toIso8601String(),
      'profilePic': profilePic,
      'name': name,
      'status': status,
      'major': major,
      'fromGender': fromGender
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
        accepted: map['accepted'] as bool,
        from: map['from'] as String,
        to: map['to'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        timestamp: map['timestamp'] == null
            ? Timestamp.now()
            : map['timestamp'] as Timestamp,
        profilePic: map['profilePic'] as String,
        name: map['name'] as String,
        status: map['status'] as String,
        major: map['major'] as String,
        fromGender: map['fromGender'] as String);
  }
  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
