import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/service/notification_service.dart';
import 'package:near_me/features/home/data/repository/local/local_db.dart';
import 'package:near_me/features/home/domain/entities/connection_model.dart';
import 'package:near_me/features/notification/domain/entities/notif_entities.dart';
import 'package:near_me/features/notification/domain/repository/notification_repo.dart';

class NotificationRepoImpl implements NotificationRepository {
  final FirebaseFirestore firestore;
  final DatabaseHelper localDb;
  NotificationRepoImpl(this.firestore, this.localDb);

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
        .asyncMap((querySnapshot) async {
      // asyncMap allows async operations
      List<NotificationModel> notifications = [];

      // If no notifications are present, you can optionally add a dummy one
      if (querySnapshot.docs.isEmpty) {
        await firestore
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
          var notModel = NotificationModel.fromMap(doc.data());
          var conModel = ConnectionModel(
              name: notModel.name,
              profilePic: notModel.profilePic,
              id: notModel.from,
              gender: notModel.fromGender,
              isOnline: true,
              lastSeen: notModel.timestamp.toDate().toString());

          // Wait for the localDb insertion before proceeding to the next notification
          await localDb.insertConnection(conModel); // Make sure this is awaited
          notifications.add(notModel);
        }
      }

      return notifications;
    });
  }

  @override
  Future<Unit> markNotification() async {
    var userId = UserConstant().getUserId();
    var snapShot = await firestore
        .collection("notifications")
        .doc(userId)
        .collection("notification")
        .orderBy('timestamp', descending: true)
        .get();

    for (var doc in snapShot.docs) {
      await firestore
          .collection("notifications")
          .doc(userId)
          .collection("notification")
          .doc(doc.id)
          .update({'status': 'seen'});
    }
    return unit;
  }
}
