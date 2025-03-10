import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_me/core/constants/constant.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/core.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';
import 'package:near_me/features/chat/domain/repository/chat_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore fireStore;
  final SharedPreferences sharedPreferences;
  final NetworkInfo networkInfo;
  final FlutterSecureStorage secureStorage;
  ChatRepositoryImpl(this.fireStore, this.sharedPreferences, this.networkInfo,
      this.secureStorage);
  @override
  Future<Either<Failure, Unit>> sendMessage(
      {required String message, required String receiverId}) async {
    if (await networkInfo.isConnected) {
      try {
        var userId =
            await secureStorage.read(key: Constant.userIdSecureStorageKey);
        List<String> ids = [userId!, receiverId];
        ids.sort();
        var user1Id = ids[0];
        var user2Id = ids[1];
        var user1 = await fireStore.collection('users').doc(user1Id).get();
        var user2 = await fireStore.collection('users').doc(user2Id).get();

        // for chat id
        var chatId = ids.join("_");
        await fireStore.collection("chats").doc(chatId).set({
          'participants': [user2Id, user1Id],
          'lastMessage': message,
          'lastMessageTime': Timestamp.now(),
          'user1ProfilePic': user1['photoUrl'],
          'user1Name': user1['name'],
          'user1Id': user1['id'],
          'user1Gender': user1['gender'],
          'user2Id': user2['id'],
          'user2Name': user2['name'],
          'user2ProfilePic': user2['photoUrl'],
          'user2Gender': user2['gender'],
        });

        await fireStore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'message': message,
          'senderId': userId,
          'seen': false,
          'timestamp': Timestamp.now()
        });
        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Stream<List<ChatEntities>> getChats(String userId) {
    return Stream.periodic(Duration(seconds: 5)).asyncMap((_) async {
      int totalUnreadCount = 0;
      var chatSnapshot = await fireStore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      List<ChatEntities> result = [];

      for (var chat in chatSnapshot.docs) {
        var chatId = chat.id;

        // Fetch last message details
        var lastThing = chat.data();
        var lastMessage = lastThing['lastMessage'];
        var lastMessageTime = lastThing['lastMessageTime'];

        // Fetch unread messages (optimized)
        var unreadMessages = await fireStore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('seen', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .get();

        int unreadCount = unreadMessages.docs.length;
        totalUnreadCount = totalUnreadCount + unreadCount;

        ChatEntities chatEntities = ChatEntities(
            chatId: chatId,
            lastMessage: lastMessage,
            lastMessageTime: lastMessageTime,
            user1Id: lastThing['user1Id'],
            user2Name: lastThing['user2Name'],
            user2Id: lastThing['user2Id'],
            user2ProfilePic: lastThing['user2ProfilePic'],
            unreadCount: unreadCount,
            user2Gender: lastThing['user2Gender'],
            user1Gender: lastThing['user1Gender'],
            user1Name: lastThing['user1Name'],
            user1ProfilePic: lastThing['user1ProfilePic']);
        result.add(chatEntities);
      }

      return result;
    });
  }

  @override
  Future<bool> isOnline(String userId) async {
    print("checking online status");
    if (userId == '1') {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<Either<Failure, List<BubbleModel>>> getMessage(
      String receiverId, lastMessage, limit) async {
    if (await networkInfo.isConnected) {
      try {
        var user1Id = UserConstant().getUserId();

        var ids = [user1Id!, receiverId];
        ids.sort();
        var chatId = ids.join("_");

        Query query = fireStore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(limit);

        if (lastMessage != null) {
          query = query.startAfterDocument(lastMessage);
        }

        var messagesSnapshot = await query.get();

        List<BubbleModel> result = messagesSnapshot.docs
            .map((doc) => BubbleModel.fromFirestore(doc))
            .toList();
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }
}
