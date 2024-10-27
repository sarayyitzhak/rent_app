import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'models/user.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/models/category.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/address_info.dart';
import 'dart:async';

import '../models/item.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
final storageRef = FirebaseStorage.instance.ref();
File? _image;
List names = [
  'אוראל כהן',
  'בני פרץ',
  'גדעון יצחק',
  'דוד שלום',
  'הודיה בן שימול',
  'ורד כץ',
  'זלימוביץ',
  'חיים משה',
  'טובה שלומיאל',
  'ירון אילן'
];
List itemsTitles = [
  "כיסא",
  "שולחן",
  "מיטה",
  "ארון",
  "ספה",
  "מחשב",
  "טלוויזיה",
  "מקרר",
  "כיריים",
  "תנור",
  "מיקרוגל",
  "שלט",
  "מאוורר",
  "מנורה",
  "ספר",
  "כוס",
  "צלחת",
  "סכין",
  "מזלג",
  "כף",
  "שטיח",
  "כרית",
  "שמיכה",
  "וילון",
  "תמונה",
  "שטיחון",
  "טלפון",
  "מטען",
  "שקע",
  "שלט רחוק",
  "חלון",
  "דלת",
  "מגבת",
  "ברז",
  "כיור",
  "אסלה",
  "מראה",
  "שפתון",
  "מברשת שיניים",
  "סבון",
  "שמפו",
  "מרכך",
  "קרם ידיים",
  "נייר טואלט",
  "מכונת כביסה",
  "מייבש כביסה",
  "מגהץ",
  "לוח שעם",
  "מסגרת תמונה",
  "נעליים",
  "סוודר",
  "מעיל",
  "כובע",
  "מטריה",
  "מקל",
  "תיק",
  "ארנק",
  "מפתחות",
  "כרטיס אשראי",
  "משקפיים",
  "שעון",
  "טבעת",
  "שרשרת",
  "עגיל",
  "טלוויזיה",
  "שלט",
  "ממיר",
  "רמקול",
  "מחשב נייד",
  "מסך",
  "מקלדת",
  "עכבר",
  "מדפסת",
  "פקס",
  "מספריים",
  "סיכות מהדק",
  "מחדד",
  "עט",
  "עיפרון",
  "סרגל",
  "מחברת",
  "קלסר",
  "ניירות",
  "מדף",
  "ספר",
  "מנורה",
  "מאוורר",
  "כוננית",
  "ארון נעליים",
  "ארון בגדים",
  "שידה",
  "מיטה",
  "סדין",
  "כרית",
  "מראה",
  "קומקום",
  "טוסטר",
  "סכום",
  "כוסות",
  "קערה",
  "מסננת"
];
List<AddressInfo> addressValues = [
  AddressInfo(
      geoPoint: const GeoPoint(32.784809, 35.023056),
      addressData: {'city': 'חיפה', 'road': 'הרב מימון'}),
  AddressInfo(
      geoPoint: const GeoPoint(32.776475, 35.036188),
      addressData: {'city': 'נשר', 'road': 'מעלה הגיבורים'}),
  AddressInfo(
      geoPoint: const GeoPoint(31.795468, 35.153486),
      addressData: {'city': 'מוצא עילית', 'road': 'ארזה'}),
  AddressInfo(
      geoPoint: const GeoPoint(32.026828, 34.872005),
      addressData: {'city': 'אור יהודה', 'road': 'ניצן'}),
  AddressInfo(
      geoPoint: const GeoPoint(31.762280, 35.174503),
      addressData: {'city': 'ירושלים', 'road': 'קרית יובל'}),
  AddressInfo(
      geoPoint: const GeoPoint(31.746798, 35.220745),
      addressData: {'city': 'ירושלים', 'road': 'ארנונה'}),
  AddressInfo(
      geoPoint: const GeoPoint(32.815981, 35.002303),
      addressData: {'city': 'חיפה', 'road': 'עיר תחתית'}),
  AddressInfo(
      geoPoint: const GeoPoint(31.781190, 35.309961),
      addressData: {'city': 'מעלה אדומים', 'road': 'החלמיש'}),
  AddressInfo(
      geoPoint: const GeoPoint(31.767112, 35.303640),
      addressData: {'city': 'מעלה אדומים', 'road': 'צמח השדה'}),
];
List categories = ItemCategory.values;
List images = [];
final _messaging = FirebaseMessaging.instance;


Future<File> getImageFileFromAssets(String path) async {
  var image = Image.asset(path);
  final byteData = await rootBundle.load(path);

  final fileName = path.split('/').last; // Get just the file name
  final file = File('${(await getTemporaryDirectory()).path}/$fileName');

  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

Future<void> onRegisterButtonPressed(int idx) async {
  //add10users
  String? userUidRand;
  UserDetails userDetailsRand;
  DocumentReference userReference;



  String email = 'mail${idx.toString()}@gmail.com';

  final user = await _auth.signInWithEmailAndPassword(email: email, password: '123456');
  userUidRand = user.user?.uid;
  userReference = _firestore.collection('users').doc(userUidRand);
  userDetailsRand = UserDetails(
      userReference: userReference,
      name: names[idx],
      email: email,
      phoneNumber: int.parse('54808825$idx'),
      items: [],
      wishlist: [],
      seen: [],
      chats: [],
  );
  _messaging.getToken().then((String? token) {
    if (token != null) {
      userDetailsRand.token = token;
    }
  });
  userReference.set(userDetailsRand.userAsMap());

  sleep(Durations.long4);
  for (int j = 0; j < 10; j++) {
    //additems
    File image = await getImageFileFromAssets(
        'assets/images/usersImages/${categories[j].title}/$idx.jpeg'); //File('C:/Users/Sarai/StudioProjects/rent_app/images/usersImages/${categories[j].title}/$idx.jpeg');
    var itemDoc = _firestore.collection('items').doc();
    final itemRef = storageRef.child(itemDoc.id);
    if (!image.existsSync()) {
      print("File does not exist: ${image.path}");
      continue; // Skip to the next iteration if file doesn't exist
    }
    UploadTask uploadTask = itemRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    var imageDownloadUrl = await taskSnapshot.ref.getDownloadURL();

    Item newItem = Item(
        itemReference: itemDoc,
        contactUser: userDetailsRand.userReference,
        imageRef: '',
        title: itemsTitles[(idx * 10) + j],
        price: Random().nextInt(1000),
        location: addressValues[idx],
        description: 'מוצר נדיר מהמם הכי טוב שיש. מומלץ לכל אחד להשכיר.',
        condition: Condition.USED_AS_NEW,
        categories: [categories[j]],
        createdAt: Timestamp.now(),
        likesCount: 0,
        seenCount: 0
    );
    newItem.imageRef = imageDownloadUrl;
    itemDoc.set(newItem.itemToMap());

    var userGet = await userDetailsRand.userReference.get();
    if (userGet.exists) {
      Map<String, dynamic> userData = userGet.data()! as Map<String, dynamic>;
      var userItems = userData['items'];
      userDetailsRand.userReference.update({
        'items': FieldValue.arrayUnion([itemDoc])
      });
    } else{
      print('error');
    }
  }
  int x = 8;
}

void create10Users() {
  for (int i = 0; i < 10; i++) {
    onRegisterButtonPressed(i);
  }
}
