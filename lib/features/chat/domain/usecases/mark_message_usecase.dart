import 'package:dartz/dartz.dart';
import 'package:near_me/features/chat/domain/repository/chat_repository.dart';

class MarkMessageUsecase {
  final ChatRepository chatRepository;
  MarkMessageUsecase({required this.chatRepository});
  Future<Unit> call(String user2Id) {
    return chatRepository.markMessageAsSeen(user2Id);
  }
}
