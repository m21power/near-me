part of 'conversation_bloc.dart';

sealed class ConversationState extends Equatable {
  const ConversationState();
  @override
  List<Object?> get props => [];
}

final class ConversationInitial extends ConversationState {}

final class GetMessageSuccessState extends ConversationState {
  final List<BubbleModel> messages;
  final Map<String, UserStatus> userstatus;
  const GetMessageSuccessState({
    required this.messages,
    required this.userstatus,
  });

  @override
  List<Object?> get props => [messages, userstatus];
}

final class GetMessageFailureState extends ConversationState {
  final String message;
  final Map<String, UserStatus> userstatus;

  const GetMessageFailureState(this.message, this.userstatus);
}

final class SendMessageSuccessState extends ConversationState {
  SendMessageSuccessState();
}

final class SendMessageFailureState extends ConversationState {
  final String message;
  const SendMessageFailureState(this.message);
  @override
  List<Object?> get props => [message];
}

final class MessageErrorState extends ConversationState {
  final String message;
  MessageErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

final class GetConnectedUsersIdFailureState extends ConversationState {
  final String message;
  GetConnectedUsersIdFailureState(this.message);
  @override
  List<Object> get props => [message];
}
