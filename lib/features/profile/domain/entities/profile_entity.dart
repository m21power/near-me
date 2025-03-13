// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ConnectionReqModel {
  final String from;
  final String status;
  final String to;
  ConnectionReqModel(
      {required this.to, required this.from, required this.status});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'from': from,
      'status': status,
      'to': to,
    };
  }

  factory ConnectionReqModel.fromMap(Map<String, dynamic> map) {
    return ConnectionReqModel(
      from: map['from'] as String,
      status: map['status'] as String,
      to: map['to'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectionReqModel.fromJson(String source) =>
      ConnectionReqModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
