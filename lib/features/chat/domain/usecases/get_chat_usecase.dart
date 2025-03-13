import 'package:near_me/features/chat/domain/entities/chat_entities.dart';
import 'package:near_me/features/chat/domain/repository/chat_repository.dart';

class GetChatUsecase {
  final ChatRepository chatRepository;
  GetChatUsecase({required this.chatRepository});
  Stream<List<ChatEntities>> call() {
    return chatRepository.getChats();
  }
}
