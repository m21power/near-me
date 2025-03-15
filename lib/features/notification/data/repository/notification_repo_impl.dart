import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/service/notification_service.dart';
import 'package:near_me/features/notification/domain/entities/notif_entities.dart';
import 'package:near_me/features/notification/domain/repository/notification_repo.dart';

class NotificationRepoImpl implements NotificationRepository {
  final FirebaseFirestore firestore;
  NotificationRepoImpl(this.firestore);

  @override
  Stream<List<NotificationModel>> getNotification() {
    var userId = UserConstant().getUserId();
    bool isInitialLoad = true;

    return firestore
        .collection("notifications")
        .doc(userId)
        .collection("notification")
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      List<NotificationModel> notifications = [];
      // If no notifications are present, you can optionally add a dummy one
      if (querySnapshot.docs.isEmpty) {
        firestore
            .collection("notifications")
            .doc(userId)
            .collection("notification")
            .add({
          'message': 'First notification', // Example dummy data
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      for (var changes in querySnapshot.docChanges) {
        if (isInitialLoad) {
          isInitialLoad = false;
          break;
        }

        if (changes.type == DocumentChangeType.added) {
          NotificationService().showNotification(
              id: UserConstant().getNewNotificaionId(),
              title: changes.doc.data()!['title'],
              body: changes.doc.data()!['body']);
          print("New Notification Added: ${changes.doc.data()}");
        }
      }
      for (var doc in querySnapshot.docs) {
        if (doc.data()['message'] == null) {
          notifications.add(NotificationModel.fromMap(doc.data()));
        }
      }

      return notifications;
    });
  }
}
