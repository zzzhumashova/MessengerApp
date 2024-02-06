import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messenger_app/features/utils.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String avatarUrl;
  final Color backgroundColor;

  const ChatScreen({Key? key, required this.contactName, required this.avatarUrl, required this.backgroundColor}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isWriting = false;

  @override
  void initState() {
    super.initState();
    messageController.addListener(() {
      if (messageController.text.isNotEmpty && !isWriting) {
        setState(() => isWriting = true);
      } else if (messageController.text.isEmpty && isWriting) {
        setState(() => isWriting = false);
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose(); // Не забывайте освобождать ресурсы
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = currentUser?.uid;
    // Остальная часть кода остаётся без изменений
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.backgroundColor,
              backgroundImage: NetworkImage(widget.avatarUrl),
              child: widget.avatarUrl.isEmpty
                ? Text(getInitials(widget.contactName),
                    style: const TextStyle(color: Colors.white))
                : null,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.contactName),
                  const Text("В сети", style: TextStyle(fontSize: 12, color: Color.fromRGBO(94, 122, 144, 1))),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('ChatList')
                  .doc(widget.contactName) // Это должен быть идентификатор чата, а не имя контакта
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error); // Для логирования
                  return Text('Ошибка: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    bool isSentByMe = messageData['from'] == currentUserId;

                    BoxDecoration messageBoxDecoration = BoxDecoration(
                      color: isSentByMe ? Color.fromRGBO(60, 237, 120, 1) : Color.fromRGBO(237, 242, 246, 1),
                      borderRadius: BorderRadius.circular(12.0),
                    );

                    Alignment messageAlignment = isSentByMe ? Alignment.centerRight : Alignment.centerLeft;

                    return Align(
                      alignment: messageAlignment,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        decoration: messageBoxDecoration,
                        child: Text(
                          messageData['text'],
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Сообщение...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                  icon: isWriting ? Icon(Icons.send) : Icon(Icons.mic), 
                  onPressed: () {
                    if (isWriting) {
                      sendMessage(currentUserId); 
                    } else {}
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String? userId) {
    final String messageText = messageController.text.trim();
    if (messageText.isNotEmpty && userId != null) {
      firestore.collection('ChatList').doc(widget.contactName).collection('messages').add({
        'text': messageText,
        'from': userId,
        'messageTime': FieldValue.serverTimestamp(),
      });
      messageController.clear();
      setState(() => isWriting = false);
    }
  }
}

