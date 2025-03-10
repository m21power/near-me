import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/features/chat/domain/usecases/get_message_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/send_message_usecase.dart';

import '../../../../domain/entities/chat_entities.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GetMessageUsecase getMessageUsecase;
  final SendMessageUsecase sendMessageUsecase;

  ConversationBloc({
    required this.getMessageUsecase,
    required this.sendMessageUsecase,
  }) : super(ConversationInitial()) {
    on<GetMessageEvent>((event, emit) async {
      var result = await getMessageUsecase(
        event.receiverId,
        event.lastMessage, // Pagination
        event.limit,
      );

      result.fold(
        (failure) => emit(GetMessageFailureState(failure.message)),
        (newMessages) {
          if (state is GetMessageSuccessState) {
            final oldMessages = (state as GetMessageSuccessState).messages;
            final hasMore = newMessages.length == event.limit;
            emit(GetMessageSuccessState(
              messages: [...oldMessages, ...newMessages], // Append new messages
              lastMessage: newMessages.isNotEmpty
                  ? newMessages.last.documentSnapshot
                  : event.lastMessage,
              hasMore: hasMore,
            ));
          } else {
            final hasMore = newMessages.length == event.limit;
            emit(GetMessageSuccessState(
              messages: newMessages,
              lastMessage: newMessages.isNotEmpty
                  ? newMessages.last.documentSnapshot
                  : null,
              hasMore: hasMore,
            ));
          }
        },
      );
    });

    on<SendMessageEvent>((event, emit) async {
      var result = await sendMessageUsecase(
        message: event.message,
        recieverId: event.receiverId,
      );

      result.fold(
        (failure) => emit(SendMessageFailureState(failure.message)),
        (sentMessage) => emit(SendMessageSuccessState(BubbleModel(
            message: event.message,
            seen: false,
            timestamp: Timestamp.now(),
            senderId: UserConstant().getUserId()!,
            documentSnapshot: null))),
      );
    });
  }
}
