import 'package:dartz/dartz.dart';
import 'package:near_me/features/notification/domain/repository/notification_repo.dart';

class MarkNotificationAsSeenUsecase {
  final NotificationRepository notificationRepository;
  MarkNotificationAsSeenUsecase({required this.notificationRepository});
  Future<Unit> call() {
    return notificationRepository.markNotification();
  }
}
