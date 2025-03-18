import 'dart:async';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';
import 'package:near_me/features/chat/presentation/bloc/conversation/bloc/conversation_bloc.dart';

class ConversationPage extends StatefulWidget {
  final ChatEntities chatEntity;
  final bool amUser1;

  const ConversationPage(
      {super.key, required this.chatEntity, required this.amUser1});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ScrollController messageInputController = ScrollController();

  List<BubbleModel> bubbles = [];
  bool showEmoji = false;
  bool isLoading = false;
  bool allMessageFetched = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state is SendMessageSuccessState) {}

          if (state is GetMessageSuccessState) {
            widget.amUser1
                ? context
                    .read<ConversationBloc>()
                    .add(MarkMessageEvent(widget.chatEntity.user2Id))
                : context
                    .read<ConversationBloc>()
                    .add(MarkMessageEvent(widget.chatEntity.user1Id));
            setState(() {
              isLoading = false; // Stop loading when new messages are fetched
            });
          }
        },
        builder: (context, state) {
          if (state is GetMessageSuccessState) {
            bubbles = state.messages;
          }

          return Scaffold(
            appBar: buildAppBar(context),
            body: Column(
              children: [
                Expanded(
                  child: bubbles.isEmpty
                      ? const Center(child: Text("No messages yet"))
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(10),
                          reverse: true,
                          itemCount: bubbles.length,
                          itemBuilder: (context, index) {
                            bool isMe = bubbles[index].senderId ==
                                (widget.amUser1
                                    ? widget.chatEntity.user1Id
                                    : widget.chatEntity.user2Id);
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child:
                                  messageBubble(context, isMe, bubbles[index]),
                            );
                          },
                        ),
                ),
                if (isLoading) // Show loading indicator if fetching messages
                  const Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(),
                  ),
                buildMessageInput(context),
                Offstage(
                  offstage: !showEmoji,
                  child: buildEmojiPicker(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 4,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("under development")));
          },
          icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
        )
      ],
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: widget.amUser1
                ? AssetImage(widget.chatEntity.user2Gender == 'male'
                    ? "assets/male.png"
                    : "assets/woman.png")
                : AssetImage(widget.chatEntity.user1Gender == 'male'
                    ? "assets/male.png"
                    : "assets/woman.png"),
            foregroundImage: widget.amUser1
                ? (widget.chatEntity.user2ProfilePic.isNotEmpty
                    ? NetworkImage(widget.chatEntity.user2ProfilePic)
                    : null)
                : (widget.chatEntity.user1ProfilePic.isNotEmpty
                    ? NetworkImage(widget.chatEntity.user1ProfilePic)
                    : null),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.amUser1
                    ? widget.chatEntity.user2Name
                    : widget.chatEntity.user1Name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Online",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onTap: () {
                if (showEmoji) {
                  setState(() {
                    showEmoji = false;
                  });
                }
              },
              controller: messageController,
              scrollController: messageInputController, // Use new controller
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                  hintText: "Write a message...", border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.teal),
            onPressed: () {
              setState(() {
                showEmoji = !showEmoji;
              });
            },
          ),
          IconButton(
              icon: const Icon(Icons.send, color: Colors.teal),
              onPressed: () {
                if (messageController.text.trim().isNotEmpty) {
                  final receiverId = widget.amUser1
                      ? widget.chatEntity.user2Id
                      : widget.chatEntity.user1Id;
                  context.read<ConversationBloc>().add(
                      SendMessageEvent(messageController.text, receiverId));
                  messageController.clear();
                }
              }),
        ],
      ),
    );
  }

  Widget buildEmojiPicker() {
    return EmojiPicker(
      textEditingController: messageController,
      scrollController: messageInputController, // Use new controller
      config: Config(
        height: 256,
        checkPlatformCompatibility: true,
        viewOrderConfig: const ViewOrderConfig(),
        emojiViewConfig: EmojiViewConfig(
          emojiSizeMax: 28 *
              (foundation.defaultTargetPlatform == TargetPlatform.iOS
                  ? 1.2
                  : 1.0),
        ),
        skinToneConfig: const SkinToneConfig(),
        categoryViewConfig: const CategoryViewConfig(),
        bottomActionBarConfig: const BottomActionBarConfig(),
        searchViewConfig: const SearchViewConfig(),
      ),
    );
  }

  Widget messageBubble(
      BuildContext context, bool isMe, BubbleModel bubbleModel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
            : Colors.green.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bubbleModel.message,
              style: const TextStyle(color: Colors.white), softWrap: true),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat('HH:mm').format(bubbleModel.timestamp.toDate()),
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(width: 5),
              if (isMe)
                Icon(bubbleModel.seen ? Icons.done_all : Icons.done,
                    size: 16, color: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }
}
