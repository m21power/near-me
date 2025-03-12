part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

final class IsOnlineEvent extends ChatEvent {
  final String userId;
  const IsOnlineEvent(this.userId);
}

final class GetChatEvent extends ChatEvent {
  final List<ChatEntities> chatEntities;
  GetChatEvent(this.chatEntities);
}
