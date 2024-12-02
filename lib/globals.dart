
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'models/chat.dart';
import 'models/user.dart';

String? userUid;
late UserDetails userDetails;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Chat? activeChat;
