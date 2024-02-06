// chat_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/features/utils.dart';
import 'chat_list_item.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String filter = '';

  void setFilter(String value) {
    setState(() {
      filter = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Чаты')),
      body: Column(
        children: [
          SearchBar(onFilter: setFilter),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('ChatList').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Ошибка загрузки данных');
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final chatTitle = doc.get('chatTitle').toString().toLowerCase();
                  return chatTitle.contains(filter);
                }).toList();

                return ListView(
                  children: filteredDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    return ChatListItem(
                      contactName: data['chatTitle'] ?? 'Без названия',
                      photoUrl: data['photoUrl'] ?? '',
                      lastMessage: data['lastMessage'] ?? 'Нет сообщений',
                      lastMessageTime: data['lastMessageTime'] as Timestamp, 
                      avatarBackgroundColor: getRandomColor(),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class SearchBar extends StatelessWidget {
  final Function(String) onFilter;

  const SearchBar({Key? key, required this.onFilter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) => onFilter(value), // Используем onFilter здесь
        style: const TextStyle(color: Color.fromRGBO(157, 183, 203, 1)),
        decoration: InputDecoration(
          hintText: 'Поиск...',
          hintStyle: const TextStyle(color: Color.fromRGBO(157, 183, 203, 1)),
          prefixIcon: const Icon(Icons.search, color: Color.fromRGBO(157, 183, 203, 1)),
          fillColor: const Color.fromRGBO(237, 242, 246, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}


      
