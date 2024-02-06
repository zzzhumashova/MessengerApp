//message_list.dart
import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  final List<String> messages;

  MessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index]),
          );
        },
      ),
    );
  }
}
