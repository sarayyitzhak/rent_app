
import 'package:cloud_firestore/cloud_firestore.dart';

class AddressInfo{
  GeoPoint geoPoint;
  Map addressData;
  AddressInfo({required this.geoPoint, required this.addressData});

  String addressDataToString(){
    return '${addressData['city']}${(addressData['road'] != '' && addressData['road'] != null) ? ',  ${addressData['road']}' : ''}';
  }

  Map<String, dynamic> toMap(){
    return {
      'geoPoint': geoPoint,
      'city': addressData['city'],
      'road': addressData['road'] ?? '',
    };
  }
}

AddressInfo mapToAddressInfo(Map<String, dynamic> map){
  return AddressInfo(geoPoint: map['geoPoint'], addressData: {'city': map['city'], 'road': map['road']});
}




