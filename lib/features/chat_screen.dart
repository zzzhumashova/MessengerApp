import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:messenger_app/features/utils.dart';

class ChatScreen extends StatefulWidget {
  final String documentId;
  final String chatTitle;
  final Color backgroundColor;

  const ChatScreen({
    super.key,
    required this.documentId,
    required this.chatTitle,
    required this.backgroundColor,
    required String contactName,
    required Null Function(String contactName, String lastMessage)
        updateLastMessage,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
  
}

class ChatScreenState extends State<ChatScreen> {
  final FocusNode _messageFocusNode = FocusNode();
  final String mainUserId = 'me';
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    _messageFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }


  void sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) {
      return;
    }

    DocumentReference messageDoc = _firestore
        .collection('ChatList')
        .doc(widget.documentId)
        .collection('messages')
        .doc();

    Map<String, dynamic> messageData = {
      'from': mainUserId,
      'text': messageText,
      'messageTime': FieldValue.serverTimestamp(),
    };

    await messageDoc.set(messageData);

    await _firestore.collection('ChatList').doc(widget.documentId).update({
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('ChatList')
                .doc(widget.documentId)
                .snapshots(),
            builder: (context, snapshot) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
                leading: CircleAvatar(
                  radius: 34,
                  backgroundColor: widget.backgroundColor,
                  child: Text(
                    getInitials(widget.chatTitle),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                title: Text(
                  data['chatTitle'] ?? 'Not Found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(data['isActive'] ? 'в сети' : 'не в сети',
                    style: const TextStyle(
                      fontSize: 12,
                    )),
              );
            },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('ChatList')
                  .doc(widget.documentId)
                  .collection('messages')
                  .orderBy('messageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        messages[index].data() as Map<String, dynamic>;
                    final bool isMainUser = data['from'] == mainUserId;
                    final Timestamp messageTime = data['messageTime'];
                    final String formattedTime =
                        DateFormat('HH:mm').format(messageTime.toDate());

                    return Align(
                      alignment: isMainUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: isMainUser ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data['text'],
                              style: const TextStyle(color: Colors.black),
                            ),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 70.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    iconSize: 25.0,
                    color: Theme.of(context).primaryColor,
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _messageFocusNode,
                      controller: _messageController,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Сообщение',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_messageFocusNode.hasFocus ? Icons.send : Icons.mic),
                    iconSize: 25.0,
                    color: Theme.of(context).primaryColor,
                    onPressed: _messageFocusNode.hasFocus ? sendMessage : (){}
                    ),
                ]
              ) 
            )
          )
        ],
      ),
    );
  }
}