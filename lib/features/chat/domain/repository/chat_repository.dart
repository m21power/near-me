import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';

abstract class ChatRepository {
  Future<Either<Failure, Unit>> sendMessage(
      {required String message, required String receiverId});
  Stream<List<ChatEntities>> getChats();
  Stream<List<BubbleModel>> getMessage(String receiverId);
  Future<Unit> markMessageAsSeen(String user2Id);
  Stream<Map<String, UserStatus>> getUsersStatus(List<String> ids);
  Future<Either<Failure, List<String>>> getConnectedUsersId();
}
