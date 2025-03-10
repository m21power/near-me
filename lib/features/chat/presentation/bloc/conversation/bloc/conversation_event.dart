part of 'conversation_bloc.dart';

sealed class ConversationEvent {
  const ConversationEvent();
}

final class GetMessageEvent extends ConversationEvent {
  final String receiverId;
  final DocumentSnapshot? lastMessage; // For pagination
  final int limit;

  const GetMessageEvent(this.receiverId, {this.lastMessage, this.limit = 20});
}

final class SendMessageEvent extends ConversationEvent {
  final String message;
  final String receiverId;

  const SendMessageEvent(this.message, this.receiverId);
}
