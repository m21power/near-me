import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/features/chat/domain/usecases/get_connected_users_id_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/get_message_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/get_users_status.dart';
import 'package:near_me/features/chat/domain/usecases/mark_message_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/send_message_usecase.dart';

import '../../../../domain/entities/chat_entities.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GetMessageUsecase getMessageUsecase;
  final SendMessageUsecase sendMessageUsecase;
  final MarkMessageUsecase markMessageUsecase;
  final GetUsersStatusUsecase getUsersStatusUsecase;
  final GetConnectedUsersIdUsecase getConnectedUsersIdUsecase;
  StreamSubscription? messageSubscription;
  StreamSubscription<Map<String, dynamic>>? statusSubscription;

  Map<String, UserStatus>? userStatus;

  ConversationBloc({
    required this.getUsersStatusUsecase,
    required this.getConnectedUsersIdUsecase,
    required this.getMessageUsecase,
    required this.sendMessageUsecase,
    required this.markMessageUsecase,
  }) : super(ConversationInitial()) {
    on<SendMessageEvent>((event, emit) async {
      var result = await sendMessageUsecase(
        message: event.message,
        recieverId: event.receiverId,
      );

      result.fold(
        (failure) => emit(SendMessageFailureState(failure.message)),
        (sentMessage) => emit(SendMessageSuccessState()),
      );
    });
    on<GetMessageEvent>(
      (event, emit) async {
        await messageSubscription?.cancel();

        messageSubscription = getMessageUsecase(event.receiverId).listen(
          (value) async {
            await Future.delayed(Duration.zero); // Ensure async execution
            emit(GetMessageSuccessState(
                messages: value,
                userstatus: userStatus ?? Map<String, UserStatus>()));
          },
          onError: (error) async {
            await Future.delayed(Duration.zero);
            emit(MessageErrorState(error.toString()));
          },
        );
        await messageSubscription
            ?.asFuture(); // Keeps handler alive until stream ends
      },
    );
    on<MarkMessageEvent>(
      (event, emit) async {
        await markMessageUsecase(event.userId);
      },
    );
    // on<GetStatusEvent>((event, emit) async {
    //   await statusSubscription?.cancel();
    //   statusSubscription = getUsersStatusUsecase(event.ids).listen(
    //     (value) async {
    //       await Future.delayed(Duration.zero); // Ensure async execution
    //       userStatus = value;
    //       emit(GetUserStatusSuccessState(value));
    //     },
    //     onError: (error) async {
    //       await Future.delayed(Duration.zero);
    //       emit(GetUserStatusFailureState(error.toString()));
    //     },
    //   );

    //   await statusSubscription
    //       ?.asFuture(); // Keeps handler alive until stream ends
    // });
    // on<GetConnectedUsersId>(
    //   (event, emit) async {
    //     var result = await getConnectedUsersIdUsecase();
    //     result.fold((l) => emit(GetConnectedUsersIdFailureState(l.message)),
    //         (r) => add(GetStatusEvent(r)));
    //   },
    // );
  }
  @override
  Future<void> close() {
    statusSubscription?.cancel();

    messageSubscription?.cancel();
    return super.close();
  }
}
