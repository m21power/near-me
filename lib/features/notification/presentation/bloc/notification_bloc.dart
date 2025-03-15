import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/features/notification/domain/entities/notif_entities.dart';
import 'package:near_me/features/notification/domain/usecases/get_notifications_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  StreamSubscription<List<NotificationModel>>? notifictionStream;
  final GetNotificationsUsecase getNotificationsUsecase;
  NotificationBloc({required this.getNotificationsUsecase})
      : super(NotificationInitial()) {
    on<GetNotificationEvent>(
      (event, emit) async {
        await notifictionStream?.cancel();
        notifictionStream = getNotificationsUsecase().listen(
          (value) async {
            await Future.delayed(Duration.zero);
            int totalUnreadCount = 0;
            for (var not in value) {
              if (not.status == 'unseen') {
                totalUnreadCount += 1;
              }
            }
            emit(GetNotificationSuccessState(value, totalUnreadCount));
          },
          onError: (error) async {
            await Future.delayed(Duration.zero);
            emit(NotificationError(error.toString()));
          },
        );
        await notifictionStream
            ?.asFuture(); // Keeps handler alive until stream ends
      },
    );
  }
  @override
  Future<void> close() {
    notifictionStream?.cancel();
    return super.close();
  }
}
