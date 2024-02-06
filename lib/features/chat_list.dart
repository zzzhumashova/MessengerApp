//chat_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger_app/features/utils.dart';
import 'chat_list_item.dart';

class ChatList extends StatelessWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('ChatList').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Что-то пошло не так');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return ChatListItem(
              contactName: data['chatTitle'] ?? 'Без названия',
              lastMessage: data['lastMessage'] ?? 'Нет сообщений',
              lastMessageTime: data['lastMessageTime'] as Timestamp?, // Прямая передача Timestamp
              photoUrl: data['photoUrl'] ?? '',
              avatarBackgroundColor: getRandomColor(), // Рандомный цвет фона аватарки
            );
          }).toList(),
        );
      },
    );
  }
}
