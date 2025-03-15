import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/notification/domain/entities/notif_entities.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getNotification();
}
