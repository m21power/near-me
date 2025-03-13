part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

final class GetChatEvent extends ChatEvent {
  GetChatEvent();
}
