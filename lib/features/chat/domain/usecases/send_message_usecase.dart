import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/chat/domain/repository/chat_repository.dart';

class SendMessageUsecase {
  final ChatRepository chatRepository;
  SendMessageUsecase({required this.chatRepository});
  Future<Either<Failure, Unit>> call(
      {required String message, required String recieverId}) {
    return chatRepository.sendMessage(message: message, receiverId: recieverId);
  }
}
