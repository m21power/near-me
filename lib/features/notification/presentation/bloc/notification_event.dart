part of 'notification_bloc.dart';

sealed class NotificationEvent {
  const NotificationEvent();
}

final class GetNotificationEvent extends NotificationEvent {}

final class MarkNotificationEvent extends NotificationEvent {}
