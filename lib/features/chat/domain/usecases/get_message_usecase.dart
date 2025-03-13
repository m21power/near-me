import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';
import 'package:near_me/features/chat/domain/repository/chat_repository.dart';

class GetMessageUsecase {
  final ChatRepository chatRepository;
  GetMessageUsecase({required this.chatRepository});
  Stream<List<BubbleModel>> call(String recieverId) {
    return chatRepository.getMessage(recieverId);
  }
}
