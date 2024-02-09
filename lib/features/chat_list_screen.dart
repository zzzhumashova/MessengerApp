// chat_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/features/utils.dart';
import 'chat_list_item.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  String filter = '';

  void setFilter(String value) {
    setState(() {
      filter = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Text(
                    'Чаты',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
          )),
      body: Column(
        children: [
          SearchBar(onFilter: setFilter),
          const Divider(color: Color.fromRGBO(237, 242, 246, 1),),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('ChatList').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Ошибка загрузки данных');
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.black,
                  ));
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final chats = doc.data() as Map<String, dynamic>;
                  final chatTitle = chats['chatTitle'].toLowerCase() ?? 'Chat Title';
                  return chatTitle.contains(filter);
                }).toList();


                return Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                  child: ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = filteredDocs[index];
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                  
                      return ChatListItem(
                        contactName: data['chatTitle'] ?? 'Без названия',
                        photoUrl: data['photoUrl'] ?? '',
                        lastMessage: data['lastMessageFrom'] == 'me' ? 'Вы: ${data['lastMessage']}' : data['lastMessage'],
                        lastMessageTime: data['lastMessageTime'] as Timestamp?,
                        avatarBackgroundColor: getRandomColor(), 
                        documentId: document.id, 
                      );
                    },
                  ),
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

  const SearchBar({super.key, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
        left: 20.0,
        top: 6.0,
        bottom: 20.0,
      ),
      child: SizedBox(
        height: 42,
        child: TextField(
          onChanged: (value) => onFilter(value),
          style: const TextStyle(color: Color.fromRGBO(157, 183, 203, 1)),
          decoration: InputDecoration(
            hintText: 'Поиск...',
            hintStyle: const TextStyle(color: Color.fromRGBO(157, 183, 203, 1)),
            prefixIcon: const Icon(Icons.search,size: 24,
                color: Color.fromRGBO(157, 183, 203, 1)),
            fillColor: const Color.fromRGBO(237, 242, 246, 1),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
    );
  }
}
