import 'package:near_me/features/chat/domain/repository/chat_repository.dart';

import '../entities/chat_entities.dart';

class GetUsersStatusUsecase {
  final ChatRepository chatRepository;
  GetUsersStatusUsecase({required this.chatRepository});
  Stream<Map<String, UserStatus>> call(List<String> ids) {
    return chatRepository.getUsersStatus(ids);
  }
}
