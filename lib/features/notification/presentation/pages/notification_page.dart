import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/features/chat/presentation/bloc/conversation/bloc/conversation_bloc.dart';
import 'package:near_me/features/chat/presentation/pages/conversation_page.dart';
import 'package:near_me/features/notification/domain/entities/notif_entities.dart';
import 'package:near_me/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:near_me/features/profile/presentation/bloc/profile_bloc.dart';

import '../../../../core/constants/user_constant.dart';
import '../../../chat/domain/entities/chat_entities.dart';

class NotificationPage extends StatefulWidget {
  List<NotificationModel> notiModels;
  NotificationPage({super.key, required this.notiModels});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, notiState) {
        print(notiState);
        if (notiState is GetNotificationSuccessState) {
          if (notiState.notification.isNotEmpty) {
            widget.notiModels = notiState.notification;
          } else {
            context.read<NotificationBloc>().add(GetNotificationEvent());
          }
        }
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text("My Requests"),
              centerTitle: true,
            ),
            body: widget.notiModels.isEmpty
                ? const Center(
                    child: Text("No connectioin requests yet"),
                  )
                : ListView.builder(
                    itemCount: widget.notiModels.length,
                    itemBuilder: (context, index) =>
                        NotiTile(context, widget.notiModels[index])),
          ),
        );
      },
    );
  }

  Padding NotiTile(BuildContext context, NotificationModel notiModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: notiModel.status == "unseen"
              ? const Color.fromARGB(255, 158, 180, 197)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 4, right: 4),
          leading: CircleAvatar(
              radius: 25,
              backgroundImage: notiModel.fromGender == 'male'
                  ? AssetImage('assets/male.png')
                  : AssetImage('assets/womain.png'),
              foregroundImage: notiModel.profilePic != ''
                  ? CachedNetworkImageProvider(notiModel.profilePic,
                      cacheManager: MyCacheManager())
                  : null),
          title: Text(
            notiModel.name, // Name
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            notiModel.major, // Major
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          trailing: notiModel.accepted
              ? IconButton(
                  onPressed: () {
                    context
                        .read<ConversationBloc>()
                        .add(GetMessageEvent(notiModel.from));
                    var user = UserConstant().getUser();
                    ChatEntities chatEntity = ChatEntities(
                        chatId: '',
                        lastMessage: '',
                        lastMessageTime: Timestamp.now(),
                        user1Id: user!.id,
                        user2Name: notiModel.name,
                        user2Id: notiModel.from,
                        user2ProfilePic: notiModel.profilePic ?? '',
                        unreadCount: 0,
                        totalUnreadCount: 0,
                        user2Gender: notiModel.fromGender,
                        user1Gender: user.gender ?? '',
                        user1Name: user.name ?? '',
                        user1ProfilePic: user.photoUrl ?? '');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConversationPage(
                                chatEntity: chatEntity, amUser1: true)));
                  },
                  icon: FaIcon(FontAwesomeIcons.rocketchat,
                      color: Theme.of(context).colorScheme.onPrimary),
                )
              : SizedBox(
                  width: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Decline",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<ProfileBloc>()
                              .add(AcceptConReqEvent(notiModel.from));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Accept",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
