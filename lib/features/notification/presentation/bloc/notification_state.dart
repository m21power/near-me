part of 'notification_bloc.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

final class NotificationInitial extends NotificationState {}

final class GetNotificationSuccessState extends NotificationState {
  final int totalUnreadCount;
  final List<NotificationModel> notification;
  GetNotificationSuccessState(this.notification, this.totalUnreadCount);
  @override
  List<Object> get props => [notification];
}

final class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
  @override
  List<Object> get props => [message];
}
