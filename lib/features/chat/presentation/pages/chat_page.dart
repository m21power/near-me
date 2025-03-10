import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';
import 'package:near_me/features/chat/presentation/pages/conversation_page.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/conversation/bloc/conversation_bloc.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatEntities> chatEntities = [
    // ChatEntities(
    //     chatId: "dafaf",
    //     lastMessage: "love you too",
    //     lastMessageTime: Timestamp.now(),
    //     recieverId: 'JIuJLShL8jSPrcmXjnJYMqo8e1z1',
    //     senderName: 'Mesay',
    //     gender: 'male',
    //     senderId: 'uAbcTJRavsgmPYNlUpKIYh9kV4B2',
    //     senderProfilePic:
    //         'https://res.cloudinary.com/dl6vahv6t/image/upload/v1740981424/JIuJLShL8jSPrcmXjnJYMqo8e1z1/profileImage.jpg',
    //     unreadCount: 3),
    // ChatEntities(
    //     chatId: "dafaf",
    //     lastMessage: "wtf is this",
    //     lastMessageTime: Timestamp.now(),
    //     recieverId: 'uAbcTJRavsgmPYNlUpKIYh9kV4B2',
    //     senderName: 'Abel',
    //     senderId: 'JIuJLShL8jSPrcmXjnJYMqo8e1z1',
    //     gender: 'male',
    //     senderProfilePic:
    //         "https://res.cloudinary.com/dl6vahv6t/image/upload/v1741457455/uAbcTJRavsgmPYNlUpKIYh9kV4B2/profileImage.jpg",
    //     unreadCount: 1)
  ];

  // late Timer _timer;
  bool? amUser1;
  // @override
  // void initState() {
  //   super.initState();
  //   _startOnlineStatusUpdater();
  // }

  // void _startOnlineStatusUpdater() {
  //   final chatBloc = context.read<ChatBloc>();

  //   // Initial call
  //   _updateOnlineStatus(chatBloc);

  //   // Run every 1 minute
  //   _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
  //     _updateOnlineStatus(chatBloc);
  //   });
  // }

  // void _updateOnlineStatus(ChatBloc chatBloc) {
  //   for (var chat in chatEntities) {
  //     if (!isTheUserReciever!) {
  //       chatBloc.add(IsOnlineEvent(chat.receiverId));
  //     } else {
  //       chatBloc.add(IsOnlineEvent(chat.senderId));
  //     }
  //   }
  // }

  // @override
  // void dispose() {
  //   _timer.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        // print("state: $state");
        if (state is GetChatEntitiesState) {
          chatEntities = state.chatEntites;
          if (chatEntities.isNotEmpty) {
            var userId = UserConstant().getUserId();
            if (userId == chatEntities[0].user1Id) {
              amUser1 = true;
            } else {
              amUser1 = false;
            }
          }
        }
        if (state is ChatInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (chatEntities.isEmpty) {
          return const Center(child: Text("No chats"));
        }
        return ListView.builder(
          itemCount: chatEntities.length,
          itemBuilder: (context, index) {
            final chat = chatEntities[index];
            // final isOnline = (state is IsOnlineState &&
            //         state.onlineStatus.containsKey(
            //             !isTheUserReciever! ? chat.receiverId : chat.senderId))
            //     ? state.onlineStatus[!isTheUserReciever!
            //             ? chat.receiverId
            //             : chat.senderId] ??
            //         false
            //     : false;

            return ChatListItem(
              chatEntity: chat,
              isOnline: true,
              amUser1: amUser1!,
            );
          },
        );
      },
    );
  }
}

class ChatListItem extends StatelessWidget {
  final ChatEntities chatEntity;
  final bool isOnline;
  final bool amUser1;

  const ChatListItem(
      {required this.chatEntity,
      required this.isOnline,
      required this.amUser1,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        amUser1
            ? context.read<ConversationBloc>().add(GetMessageEvent(
                chatEntity.user2Id,
                lastMessage: null,
                limit: 20))
            : context.read<ConversationBloc>().add(GetMessageEvent(
                chatEntity.user1Id,
                lastMessage: null,
                limit: 20));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationPage(
                      chatEntity: chatEntity,
                      amUser1: amUser1,
                    )));
      },
      title: Text(amUser1 ? chatEntity.user2Name : chatEntity.user1Name),
      subtitle: Text(chatEntity.lastMessage),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: amUser1
                ? (chatEntity.user2Gender == 'male'
                    ? const AssetImage("assets/male.png")
                    : const AssetImage("assets/woman.png"))
                : (chatEntity.user1Gender == 'male'
                    ? const AssetImage("assets/male.png")
                    : const AssetImage("assets/woman.png")),
            foregroundImage: amUser1
                ? (chatEntity.user2ProfilePic.isNotEmpty
                    ? NetworkImage(chatEntity.user2ProfilePic)
                    : null)
                : (chatEntity.user1ProfilePic.isNotEmpty
                    ? NetworkImage(chatEntity.user1ProfilePic)
                    : null),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.blueGrey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      trailing: chatEntity.unreadCount > 0
          ? CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                chatEntity.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
    );
  }
}
