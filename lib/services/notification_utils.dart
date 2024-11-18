import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/screens/chat_screen.dart';
import '../models/chat.dart';
import '../screens/user_items_screen.dart';
import 'cloud_services.dart';

int counter = 0;

Future<void> showNotification(int id, String? title, String? body, RemoteMessage? message) async {
  await flutterLocalNotificationsPlugin.show(
    counter++,
    title,
    body,
    platformChannelSpecifics,
    payload: message?.data['click_action'], // Optional, can be used to navigate when tapping on the notification
  );
}

Future<void> handleNotificationTap(BuildContext context, Map<String, dynamic> data) async {
  final type = data['type'];
  if (type == 'CHAT') {
    final chatId = data['chatId'];
    Chat chat = await getChatFromChatID(chatId);
    Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArguments(chat));
  } else if (type == 'REQUEST') {
    Navigator.pushNamed(context, UserItemsScreen.id, arguments: UserItemsScreenArguments(showRequests: true));
  }
}

Future<void> handleNotificationOnBackGround(RemoteNotification notification) async {
  flutterLocalNotificationsPlugin.show(0, notification.title, notification.body, platformChannelSpecifics);

}