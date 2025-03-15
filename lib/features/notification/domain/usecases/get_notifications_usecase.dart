import 'package:near_me/features/notification/domain/entities/notif_entities.dart';
import 'package:near_me/features/notification/domain/repository/notification_repo.dart';

class GetNotificationsUsecase {
  final NotificationRepository notificationRepository;
  GetNotificationsUsecase({required this.notificationRepository});
  Stream<List<NotificationModel>> call() {
    return notificationRepository.getNotification();
  }
}
