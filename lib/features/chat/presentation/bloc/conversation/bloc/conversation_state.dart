part of 'conversation_bloc.dart';

sealed class ConversationState extends Equatable {
  const ConversationState();
  @override
  List<Object?> get props => [];
}

final class ConversationInitial extends ConversationState {}

final class GetMessageSuccessState extends ConversationState {
  final List<BubbleModel> messages;
  final DocumentSnapshot? lastMessage; // Store last loaded message
  final bool hasMore; // Indicate if more messages exist

  const GetMessageSuccessState({
    required this.messages,
    this.lastMessage,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [messages, lastMessage, hasMore];
}

final class GetMessageFailureState extends ConversationState {
  final String message;
  const GetMessageFailureState(this.message);
}

final class SendMessageSuccessState extends ConversationState {
  final BubbleModel sentMessage;
  SendMessageSuccessState(this.sentMessage);
  @override
  List<Object?> get props => [sentMessage];
}

final class SendMessageFailureState extends ConversationState {
  final String message;
  const SendMessageFailureState(this.message);
}
