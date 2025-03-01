import 'package:flutter/material.dart';
import 'package:near_me/features/chat/presentation/pages/conversation_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ConversationPage()));
            },
            title: const Text('Name'),
            subtitle: const Text('Last text '),
            trailing: const Text('Last seen time'),
            leading: Stack(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage("assets/male.png"),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
