import 'dart:async';
import '../constants.dart';



class AddressInfo{
  double latitude;
  double longitude;
  Map addressData;
  AddressInfo({required this.latitude, required this.longitude, required this.addressData});

  String addressDataToString(){
    return '${addressData['city']}${(addressData['road'] != '' && addressData['road'] != null) ? ',  ${addressData['road']}' : ''}';
  }
}




