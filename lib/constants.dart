

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const kYellowLogoImage = 'images/handshake_yellow.png';
const kWhiteLogoImage = 'images/handshake.png';
const kGoogleApiKey = 'AIzaSyDHz-rjDLdurz6ugj5oXvG4DaeRfR0QXIA';
const kMapTilerApiKey = '90JJ6DPLZWrrH2aGs87z';

const kMapUrl = 'https://api.maptiler.com/maps/basic-v2/{z}/{x}/{y}.png?key=$kMapTilerApiKey';

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
  fontSize: 24,
  fontWeight: FontWeight.bold,
);


const kTextFieldHintTextStyle = TextStyle(
  color: kPastelYellow,
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
  fillColor: kLightYellow,
  labelStyle: TextStyle(color: kPastelYellow),
  hintStyle: kTextFieldHintTextStyle,
);

const kDarkButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(kPastelYellow),
  textStyle: WidgetStatePropertyAll(kButtonTextStyle),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
);

const kLightButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(kLightYellow),
  textStyle: WidgetStatePropertyAll(kButtonTextStyle),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
);

const kAddressButtonStyle = ButtonStyle(
  alignment: Alignment.topRight,
  fixedSize: WidgetStatePropertyAll(Size(400, 20)),
  backgroundColor: WidgetStatePropertyAll(kLightYellow),
  textStyle: WidgetStatePropertyAll(kSmallBlackTextStyle),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
);

const kDarkYellow = Color(0xFFFFC30B);
const kLightYellow = Color(0xFFFAF0E6);
const kPastelYellow = Color(0xFFFFDB9D);
const kActiveButtonColor = Color(0xFFFFD181);
const kBlackColor = Color(0xFF000000);
const kWhiteColor = Color(0xFFFFFFFF);