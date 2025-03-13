part of 'conversation_bloc.dart';

sealed class ConversationEvent {
  const ConversationEvent();
}

final class GetMessageEvent extends ConversationEvent {
  final String receiverId;

  const GetMessageEvent(this.receiverId);
}

final class SendMessageEvent extends ConversationEvent {
  final String message;
  final String receiverId;

  const SendMessageEvent(this.message, this.receiverId);
}

final class MarkMessageEvent extends ConversationEvent {
  final String userId;
  const MarkMessageEvent(this.userId);
}

final class GetStatusEvent extends ConversationEvent {
  List<String> ids;
  GetStatusEvent(this.ids);
}

final class GetConnectedUsersId extends ConversationEvent {}
