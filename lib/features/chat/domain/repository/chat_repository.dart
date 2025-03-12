import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';

abstract class ChatRepository {
  Future<Either<Failure, Unit>> sendMessage(
      {required String message, required String receiverId});
  Stream<List<ChatEntities>> getChats(String userId);
  Future<bool> isOnline(String userId);
  Future<Either<Failure, List<BubbleModel>>> getMessage(
      String receiverId, DocumentSnapshot? lastMessage, int limit);
}
