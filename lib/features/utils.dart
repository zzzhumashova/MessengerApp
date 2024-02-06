//utils
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

Color getRandomColor() {
  final Random random = Random();
  return Color.fromRGBO(
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
    1,
  );
}

Color getAvatarBackgroundColor(String contactName) {
  return getRandomColor();
}

String getInitials(String name) {
  List<String> names = name.split(" ");
  String initials = "";
  for (var i = 0; i < names.length; i++) {
    initials += names[i][0].toUpperCase();
  }
  return initials;
}

String formatLastMessageTime(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  DateTime now = DateTime.now();
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

  if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
    // Сообщение отправлено сегодня
    return DateFormat('HH:mm').format(dateTime);
  } else if (dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day) {
    // Сообщение отправлено вчера
    return 'Вчера';
  } else {
    // Сообщение отправлено более раннее время
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }
}
