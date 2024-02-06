//message_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addMessage(String chatId, String message, {String from = "me"}) async {
    await firestore.collection('ChatList').doc(chatId).collection('messages').add({
      'text': message,
      'from': from,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await firestore.collection('ChatList').doc(chatId).update({
      'lastMessage': message,
      'lastMessageFrom': from,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  Stream<String> getLastMessage(String chatId) {
    return firestore.collection('ChatList').doc(chatId).collection('messages').orderBy('timestamp', descending: true).limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.get('text') ?? 'Начните чат';
      } else {
        return 'Начните чат';
      }
    });
  }
}
