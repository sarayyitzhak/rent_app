import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../constants.dart';
import '../main.dart';


class Location{
    String cityName;
    String streetName;
    Location(this.cityName, this.streetName);
    //coordinates;
}