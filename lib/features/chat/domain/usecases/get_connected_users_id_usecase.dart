import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/chat/domain/repository/chat_repository.dart';

class GetConnectedUsersIdUsecase {
  final ChatRepository chatRepository;
  GetConnectedUsersIdUsecase({required this.chatRepository});
  Future<Either<Failure, List<String>>> call() {
    return chatRepository.getConnectedUsersId();
  }
}
