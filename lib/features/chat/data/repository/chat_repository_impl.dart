import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/core.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';
import 'package:near_me/features/chat/domain/repository/chat_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseDatabase realTimeDB;
  final SharedPreferences sharedPreferences;
  final NetworkInfo networkInfo;
  final FlutterSecureStorage secureStorage;
  final FirebaseFirestore firestore;

  ChatRepositoryImpl(this.realTimeDB, this.sharedPreferences, this.networkInfo,
      this.secureStorage, this.firestore);

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String message,
    required String receiverId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        var user1 = UserConstant().getUser();
        var user2 = await firestore.collection('users').doc(receiverId).get();

        List<String> ids = [user1!.id, receiverId];
        ids.sort();
        var chatId = ids.join("_");

        var ref = realTimeDB.ref("chats/$chatId/messages").push();
        await ref.set({
          'message': message,
          'senderId': user1.id,
          'seen': false,
          'timestamp': ServerValue.timestamp,
        });

        // Update chat metadata with last message, users' metadata, and unreadCount
        await realTimeDB.ref("chats/$chatId").update({
          'lastMessage': message,
          'lastMessageTime': ServerValue.timestamp,
          'participants': {user1.id: true, receiverId: true},
          user1.id: {
            'name': user1.name,
            'profilePic': user1.photoUrl,
            'gender': user1.gender
          },
          receiverId: {
            'name': user2['name'],
            'profilePic': user2['photoUrl'],
            'gender': user2['gender']
          },
          'unreadCount': {
            user1.id: 0,
            user2['id']: ServerValue.increment(1),
          }
        });

        return const Right(unit);
      } catch (e) {
        print("_----------------------");
        print(e.toString());
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Stream<List<ChatEntities>> getChats() {
    var user1 = UserConstant().getUser();
    return realTimeDB
        .ref("chats")
        .orderByChild("participants/${user1!.id}")
        .equalTo(true)
        .onValue
        .map((event) {
      final chatsMap = event.snapshot.value as Map<dynamic, dynamic>?;
      if (chatsMap == null || chatsMap.isEmpty) {
        // If no chats are found, return an empty list immediately
        return [];
      }

      List<ChatEntities> chats = [];
      for (var entry in chatsMap.entries) {
        final chatData = entry.value;
        // Get the participant ids (user1 and user2)
        var ids = [
          chatData['participants'].keys.first,
          chatData['participants'].keys.last
        ];

        // Identify user2 (the other participant)
        String? user2Id;
        for (var id in ids) {
          if (id != user1.id) {
            user2Id = id;
          }
        }
        // Use the saved user2 details from chat metadata
        var user2 = chatData[user2Id];

        // Fetch unread count for this chat
        var unreadCount = chatData['unreadCount']?[user1.id] ?? 0;

        chats.add(ChatEntities(
          chatId: entry.key,
          lastMessage: chatData['lastMessage'] ?? '',
          lastMessageTime:
              Timestamp.fromMillisecondsSinceEpoch(chatData['lastMessageTime']),
          user1Id: user1.id,
          user2Id: user2Id!,
          user2Name: user2['name'] ?? '',
          user2ProfilePic: user2['profilePic'] ?? '',
          unreadCount: unreadCount,
          user2Gender: user2['gender'] ?? '',
          user1Gender: user1.gender,
          user1Name: user1.name,
          totalUnreadCount: unreadCount,
          user1ProfilePic: user1.photoUrl ?? '',
        ));
      }
      return chats;
    });
  }

  // @override
  // Stream<List<ChatEntities>> getChats() {
  //   var user1 = UserConstant().getUser();
  //   return realTimeDB
  //       .ref("chats")
  //       .orderByChild("participants/${user1!.id}")
  //       .equalTo(true)
  //       .onValue
  //       .map((event) {
  //     final chatsMap = event.snapshot.value as Map<dynamic, dynamic>?;
  //     if (chatsMap == null) return [];

  //     List<ChatEntities> chats = [];
  //     for (var entry in chatsMap.entries) {
  //       final chatData = entry.value;
  //       // Get the participant ids (user1 and user2)
  //       var ids = [
  //         chatData['participants'].keys.first,
  //         chatData['participants'].keys.last
  //       ];

  //       // Identify user2 (the other participant)
  //       String? user2Id;
  //       for (var id in ids) {
  //         if (id != user1.id) {
  //           user2Id = id;
  //         }
  //       }
  //       // Use the saved user2 details from chat metadata
  //       var user2 = chatData[user2Id];

  //       // Fetch unread count for this chat
  //       var unreadCount = chatData['unreadCount']?[user1.id] ?? 0;

  //       chats.add(ChatEntities(
  //         chatId: entry.key,
  //         lastMessage: chatData['lastMessage'] ?? '',
  //         lastMessageTime:
  //             Timestamp.fromMillisecondsSinceEpoch(chatData['lastMessageTime']),
  //         user1Id: user1.id,
  //         user2Id: user2Id!,
  //         user2Name:
  //             user2['name'] ?? '', // Using user2 details from the chat metadata
  //         user2ProfilePic: user2['profilePic'] ??
  //             '', // Using user2 details from the chat metadata
  //         unreadCount: unreadCount, // Unread count for user1
  //         user2Gender: user2['gender'] ??
  //             '', // Using user2 details from the chat metadata
  //         user1Gender: user1.gender,
  //         user1Name: user1.name,
  //         totalUnreadCount:
  //             unreadCount, // Assuming total unread count is for user1
  //         user1ProfilePic: user1.photoUrl ?? '',
  //       ));
  //     }
  //     return chats;
  //   });
  // }

  @override
  Stream<List<BubbleModel>> getMessage(String receiverId) {
    var userId = UserConstant().getUserId();
    List<String> ids = [userId!, receiverId];
    ids.sort();
    var chatId = ids.join("_");

    return realTimeDB
        .ref("chats/$chatId/messages")
        .orderByChild("timestamp") // Ensure messages are ordered by timestamp
        .onValue
        .map((event) {
      final messagesMap = event.snapshot.value as Map<dynamic, dynamic>?;

      if (messagesMap == null)
        return []; // Return empty if no messages are found.
      return messagesMap.entries.map((entry) {
        final messageData = entry.value;
        return BubbleModel(
          message: messageData['message'],
          senderId: messageData['senderId'],
          seen: messageData['seen'],
          timestamp:
              Timestamp.fromMillisecondsSinceEpoch(messageData['timestamp']),
        );
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(
            a.timestamp)); // Sorting by timestamp in decreasing order
    });
  }

  @override
  Future<Unit> markMessageAsSeen(String user2Id) async {
    var userId = UserConstant().getUserId();
    List<String> ids = [userId!, user2Id];
    ids.sort();
    var chatId = ids.join("_");

    // Fetch all messages and update their 'seen' status to true
    var messagesRef = realTimeDB.ref("chats/$chatId/messages");

    var messagesSnapshot = await messagesRef.once();
    var messagesMap = messagesSnapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (messagesMap != null) {
      await Future.forEach(messagesMap.entries, (entry) async {
        var key = entry.key;
        var value = entry.value;
        // Check if the message is unread and update its 'seen' status to true
        if (value['senderId'] != userId && value['seen'] == false) {
          messagesRef.child(key).update({
            'seen': true,
          });
          // Update chat metadata with last message, users' metadata, and unreadCount
          await realTimeDB.ref("chats/$chatId").update({
            'unreadCount': {
              userId: 0,
            }
          });
        }
      });
    }
    return unit;
  }

  @override
  Stream<Map<String, UserStatus>> getUsersStatus(List<String> ids) {
    final FirebaseDatabase realTimeDB = FirebaseDatabase.instance;
    print("list of ids");
    print(ids);
    print("list of ids");
    return realTimeDB.ref("users").onValue.map((event) {
      final usersMap = event.snapshot.value as Map<dynamic, dynamic>?;
      if (usersMap == null) return {}; // Return empty if no users found

      Map<String, UserStatus> statusMap = {};
      for (var userId in ids) {
        if (usersMap.containsKey(userId)) {
          statusMap[userId] = UserStatus.fromMap({
            "online": usersMap[userId]['status']['online'] ?? false,
            "lastSeen": Timestamp.fromMillisecondsSinceEpoch(
                usersMap[userId]['status']['lastSeen'] ?? 0),
          });
        }
      }
      return statusMap;
    });
  }

  @override
  Future<Either<Failure, List<String>>> getConnectedUsersId() async {
    // return Right(
    //     ["dmbfaY2JuZQxx26WBEdMj7XPMCj2", "uAbcTJRavsgmPYNlUpKIYh9kV4B2"]);
    if (await networkInfo.isConnected) {
      try {
        var userId = UserConstant().getUserId();

        // Fetch connections where the user is the sender
        var fromConnectionsSnapshot = await firestore
            .collection("connections")
            .where("from", isEqualTo: userId)
            .where("status", isEqualTo: "accepted")
            .get();

        // Fetch connections where the user is the receiver
        var toConnectionsSnapshot = await firestore
            .collection("connections")
            .where("to", isEqualTo: userId)
            .where("status", isEqualTo: "accepted")
            .get();

        // Combine both lists of connected users
        List<String> connectedUsers = [
          ...fromConnectionsSnapshot.docs
              .map((doc) => doc.data()['to'] as String),
          ...toConnectionsSnapshot.docs
              .map((doc) => doc.data()['from'] as String)
        ];

        return Right(connectedUsers);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No Internet Connection"));
    }
  }
}
