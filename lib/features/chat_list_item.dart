import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger_app/features/utils.dart';
import 'chat_screen.dart';

class ChatListItem extends StatelessWidget {
  final String contactName;
  final String photoUrl;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final Color avatarBackgroundColor;
  final String documentId;

  const ChatListItem({
    super.key,
    required this.contactName,
    required this.photoUrl,
    required this.lastMessage,
    this.lastMessageTime,
    required this.avatarBackgroundColor,
    required this.documentId, 
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = lastMessageTime != null
        ? formatLastMessageTime(lastMessageTime!)
        : 'Время неизвестно';

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: CircleAvatar(
            radius: 34,
            backgroundColor: avatarBackgroundColor,
            child: Text(
              getInitials(contactName),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  contactName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Text(
                formattedTime,
                style: const TextStyle(
                    fontSize: 12, color: Color.fromRGBO(94, 122, 144, 1)),
              ),
            ],
          ),
          subtitle: Text(
            lastMessage,
            style: const TextStyle(
                fontSize: 12, color: Color.fromRGBO(94, 122, 144, 1)),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  backgroundColor: avatarBackgroundColor,
                  updateLastMessage: (String contactName, String lastMessage) {
                    updateLastMessage(contactName, lastMessage);
                  }, 
                  documentId: documentId, 
                  chatTitle: contactName, contactName: contactName,
                ),
              ),
            );
          },
        ),
        const Divider(
          endIndent: 20.0,
          color: Color.fromRGBO(237, 242, 246, 1),
        ),
      ],
    );
  }

  Future<void> updateLastMessage(String contactName, String lastMessage) async {
    try {
      await FirebaseFirestore.instance
          .collection('ChatList')
          .doc(documentId)
          .update({
        'lastMessage': lastMessage,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении последнего сообщения: $e');
      }
    }
  }
}
