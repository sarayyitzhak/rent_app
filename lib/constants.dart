

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const kYellowLogoImage = 'assets/images/handshake_yellow.png';
const kWhiteLogoImage = 'assets/images/handshake.png';
const kGoogleApiKey = 'AIzaSyDHz-rjDLdurz6ugj5oXvG4DaeRfR0QXIA';
const kMapTilerApiKey = '90JJ6DPLZWrrH2aGs87z';

const kMapUrl = 'https://api.maptiler.com/maps/basic-v2/{z}/{x}/{y}.png?key=$kMapTilerApiKey';

const kIconRadius = 12.0;

const kTopHeaderTextStyle = TextStyle(
  color: kDarkYellow,
  fontSize: 28,
  fontWeight: FontWeight.bold,
  letterSpacing: 1
);

const kHeadersTextStyle = TextStyle(
  color: kDarkYellow,
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const kBlackHeaderTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const kBlackTextStyle = TextStyle(
  color: kBlackColor,
  fontSize: 18,
  fontWeight: FontWeight.w400,
);


const kSmallBlackTextStyle = TextStyle(
  color: kBlackColor,
  fontSize: 12,
  fontWeight: FontWeight.w400,
);

const kButtonTextStyle = TextStyle(
  color: kDarkYellow,
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

const kWhiteTextStyle = TextStyle(
  color: kWhiteColor,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const kTextFieldHintTextStyle = TextStyle(
  color: kGreyColor,
  fontSize: 14,
  fontWeight: FontWeight.w400,
);

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kLightYellow, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kLightYellow, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  filled: true,
  fillColor: kPastelYellowOpacity,
  labelStyle: TextStyle(color: kPastelYellow),
  hintStyle: kTextFieldHintTextStyle,
);

const kTextFieldDecorationOnlyBorder = InputDecoration(
  hintText: '',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kPastelYellow, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kPastelYellow, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  filled: true,
  fillColor: Colors.white10,
  labelStyle: TextStyle(color: kPastelYellow),
  hintStyle: kTextFieldHintTextStyle,
);

const kDarkButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(kPastelYellow),
  textStyle: WidgetStatePropertyAll(kButtonTextStyle),
  elevation: WidgetStatePropertyAll(8),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
);

const kLightButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(kLightYellow),
  textStyle: WidgetStatePropertyAll(kButtonTextStyle),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
);

const kSmallButtonStyle = ButtonStyle(
backgroundColor: WidgetStatePropertyAll(kPastelYellowOpacity),
textStyle: WidgetStatePropertyAll(kBlackTextStyle),
padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
);

const kAcceptButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(Colors.green),
  textStyle: WidgetStatePropertyAll(kBlackTextStyle),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
);

const kRejectButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(Colors.red),
  textStyle: WidgetStatePropertyAll(kBlackTextStyle),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
);

const kAddressButtonStyle = ButtonStyle(
  alignment: Alignment.topRight,
  fixedSize: WidgetStatePropertyAll(Size(400, 20)),
  backgroundColor: WidgetStatePropertyAll(kPastelYellowOpacity),
  textStyle: WidgetStatePropertyAll(kSmallBlackTextStyle),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: kActiveButtonColor, width: 2.0),
  ),
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  // hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kSendButtonTextStyle = TextStyle(
  color: kActiveButtonColor,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'chat_channel_id',
    'Chat Notifications',
    channelDescription: 'Notifications for chat messages',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
    icon: 'app_icon'
);

const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);


const kDarkYellow = Color(0xFFFFC30B);
const kLightYellow = Color(0xFFFAF0E6);
const kPastelYellow = Color(0xFFFFDB9D);
const kPastelYellowOpacity = Color(0x66FFDB9D);
const kActiveButtonColor = Color(0xFFFFD181);
const kBlackColor = Color(0xFF000000);
const kWhiteColor = Color(0xFFFFFFFF);
const kBlue = Colors.lightBlueAccent;
const kGreyColor = Colors.grey;

const kUserSideBubbleEn = BorderRadius.only(
    topLeft: Radius.circular(30),
    bottomLeft: Radius.circular(30),
    bottomRight: Radius.circular(30),
);

const kContactSideBubbleEn = BorderRadius.only(
    topRight: Radius.circular(30),
    bottomLeft: Radius.circular(30),
    bottomRight: Radius.circular(30),
);