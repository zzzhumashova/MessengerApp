import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/features/utils.dart';
import 'chat_screen.dart';

class ChatListItem extends StatelessWidget {
  final String contactName;
  final String photoUrl;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final Color avatarBackgroundColor;

  const ChatListItem({
    super.key,
    required this.contactName,
    required this.photoUrl,
    required this.lastMessage,
    this.lastMessageTime,
    required this.avatarBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = lastMessageTime != null
        ? formatLastMessageTime(lastMessageTime!)
        : 'Время неизвестно';

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: avatarBackgroundColor,
            backgroundImage: NetworkImage(photoUrl),
            child: photoUrl.isEmpty
                ? Text(getInitials(contactName),
                    style: const TextStyle(color: Colors.white))
                : null,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(contactName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Text(formattedTime,
                  style: const TextStyle(
                      fontSize: 12, color: Color.fromRGBO(94, 122, 144, 1))),
            ],
          ),
          subtitle: Text(lastMessage,
              style: const TextStyle(
                  fontSize: 12, color: Color.fromRGBO(94, 122, 144, 1))),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ChatScreen(contactName: contactName, avatarUrl: photoUrl, backgroundColor: avatarBackgroundColor),
              )),
        ),
        const Divider(),
      ],
    );
  }
}
