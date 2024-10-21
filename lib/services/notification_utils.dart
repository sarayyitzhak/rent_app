import 'package:rent_app/constants.dart';
import 'package:rent_app/main.dart';
int counter = 0;

Future<void> showNotification( String? title, String? body) async {
  await flutterLocalNotificationsPlugin.show(
    counter++,
    title,
    body,
    platformChannelSpecifics,
    // payload: 'message_id', // Optional, can be used to navigate when tapping on the notification
  );
}