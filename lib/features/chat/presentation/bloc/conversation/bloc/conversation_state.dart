part of 'conversation_bloc.dart';

sealed class ConversationState extends Equatable {
  const ConversationState();
  @override
  List<Object?> get props => [];
}

final class ConversationInitial extends ConversationState {}

final class GetMessageSuccessState extends ConversationState {
  final List<BubbleModel> messages;
  const GetMessageSuccessState({
    required this.messages,
  });

  @override
  List<Object?> get props => [messages];
}

final class GetMessageFailureState extends ConversationState {
  final String message;
  const GetMessageFailureState(this.message);
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

final class GetUserStatusSuccessState extends ConversationState {
  final Map<String, UserStatus> onlineStatus;
  GetUserStatusSuccessState(this.onlineStatus);
  @override
  List<Object> get props => [onlineStatus];
}

final class GetUserStatusFailureState extends ConversationState {
  final String message;
  GetUserStatusFailureState(this.message);
  @override
  List<Object> get props => [message];
}

final class GetConnectedUsersIdFailureState extends ConversationState {
  final String message;
  GetConnectedUsersIdFailureState(this.message);
  @override
  List<Object> get props => [message];
}
