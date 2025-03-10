import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';
import 'package:near_me/features/chat/domain/usecases/get_chat_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/is_online_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  String? userId;
  Map<String, bool> onlineUsers = {};
  final IsOnlineUsecase isOnlineUsecase;
  final GetChatUsecase getChatUsecase;
  StreamSubscription<List<ChatEntities>>? chatSubscription;
  ChatBloc({
    required this.isOnlineUsecase,
    required this.getChatUsecase,
  }) : super(ChatInitial()) {
    chatSubscription = getChatUsecase(UserConstant().getUserId()!).listen(
      (event) {
        add(GetChatEvent(event));
      },
    );
    on<IsOnlineEvent>((event, emit) async {
      var result = await isOnlineUsecase(event.userId);
      onlineUsers[event.userId] = result;
      emit(IsOnlineState(onlineUsers));
    });

    on<GetChatEvent>(
      (event, emit) {
        emit(GetChatEntitiesState(event.chatEntities));
      },
    );
  }

  @override
  Future<void> close() {
    chatSubscription?.cancel();
    return super.close();
  }
}
