import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';
import 'package:near_me/features/chat/domain/usecases/get_chat_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/get_connected_users_id_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/get_users_status.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  String? userId;
  Map<String, bool> onlineUsers = {};
  final GetChatUsecase getChatUsecase;
  StreamSubscription<List<ChatEntities>>? chatSubscription;
  ChatBloc({
    required this.getChatUsecase,
  }) : super(ChatInitial()) {
    on<GetChatEvent>(
      (event, emit) async {
        emit(ChatInitial());
        await chatSubscription?.cancel();

        chatSubscription = getChatUsecase().listen(
          (value) async {
            await Future.delayed(Duration.zero); // Ensure async execution
            emit(GetChatEntitiesState(value));
          },
          onError: (error) async {
            await Future.delayed(Duration.zero);
            emit(ChatErrorState(error.toString()));
          },
        );

        await chatSubscription
            ?.asFuture(); // Keeps handler alive until stream ends
      },
    );
  }
  @override
  Future<void> close() {
    chatSubscription?.cancel();
    return super.close();
  }
}
