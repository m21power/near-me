import 'package:near_me/features/chat/domain/repository/chat_repository.dart';

class IsOnlineUsecase {
  final ChatRepository chatRepository;
  IsOnlineUsecase({required this.chatRepository});
  Future<bool> call(String userId) {
    return chatRepository.isOnline(userId);
  }
}
