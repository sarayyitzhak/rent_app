
class AddressInfo{
  double latitude;
  double longitude;
  Map addressData;
  AddressInfo({required this.latitude, required this.longitude, required this.addressData});

  String addressDataToString(){
    return '${addressData['city']}${(addressData['road'] != '' && addressData['road'] != null) ? ',  ${addressData['road']}' : ''}';
  }

  Map<String, dynamic> toMap(){
    return {
      'latitude': latitude,
      'longitude': longitude,
      'addressData': addressData
    };
  }
}

AddressInfo mapToAddressInfo(Map<String, dynamic> map){
  return AddressInfo(latitude: map['latitude'], longitude: map['longitude'], addressData: map['addressData']);
}




