part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class IsOnlineState extends ChatState {
  final Map<String, dynamic> onlineStatus;
  const IsOnlineState(this.onlineStatus);
  @override
  List<Object> get props => [onlineStatus];
}

final class GetChatEntitiesState extends ChatState {
  final List<ChatEntities> chatEntites;
  const GetChatEntitiesState(this.chatEntites);
  @override
  List<Object> get props => [chatEntites];
}
