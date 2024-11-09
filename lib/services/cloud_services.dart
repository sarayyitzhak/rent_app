import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_review.dart';
import 'package:rent_app/models/message.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/models/user_review.dart';
import 'package:rent_app/services/query_batch.dart';
import 'package:rent_app/utils.dart';
import '../models/address_info.dart';
import '../models/category.dart';
import '../models/chat.dart';
import '../models/message_type.dart';
import '../models/item_request.dart';
import '../models/request_status.dart';
import 'notification_utils.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
final _messaging = FirebaseMessaging.instance;
final storageRef = FirebaseStorage.instance.ref();


//IMAGES

Future<Uint8List?> readImage(Reference imageRef) async {
  Uint8List? data = await imageRef.getData();
  if (data != null) {
    DefaultCacheManager().putFile(imageRef.fullPath, data, key: imageRef.fullPath, fileExtension: 'jpg');
  }
  return data;
}

Future<UploadTask> uploadImage(Reference imageRef, File image) async {
  await DefaultCacheManager().putFile(imageRef.fullPath, image.readAsBytesSync(), key: imageRef.fullPath, fileExtension: 'jpg');
  return imageRef.putFile(image);
}

//ITEMS
Future<void> createNewItem(File? image, String title, String price, AddressInfo addressValue, String description, Condition condition, List<ItemCategory> categories) async {
  DocumentReference itemDoc = _firestore.collection('items').doc();
  await uploadImage(storageRef.child('items').child(itemDoc.id).child('0.jpg'), image!);

  return itemDoc.set({
    'contactUserID': userDetails.docRef.id,
    'mainImage': '0.jpg',
    'title': title,
    'price': int.parse(price),
    'location': addressValue.toMap(),
    'description': description,
    'condition': condition.index,
    'categories': categories.map((c) => c.index).toList(),
    'createdAt': FieldValue.serverTimestamp(),
    'favoriteCount': 0,
    'seenCount': 0,
  });
}

Future<void> editItem(Item item, bool isImageChanged, File? image, String title, String price, AddressInfo addressValue, String description, Condition condition, List<dynamic> categories) async {
  if(isImageChanged){
    await uploadImage(storageRef.child('items').child(item.docRef.id).child('0.jpg'), image!);
  }
  return item.docRef.update({
    'title': title,
    'price': int.parse(price),
    'location': addressValue.toMap(),
    'description': description,
    'condition': condition.index,
    'categories': categories.map((c) => c.idx).toList(),
  });
}

Reference getItemMainImageRef(DocumentReference itemRef, String mainImage) {
  return storageRef.child('items').child(itemRef.id).child(mainImage);
}

Future<QueryBatch<Item>> getItemsByCategory(ItemCategory category, [DocumentSnapshot? startAfterDoc]) async {
  Query query = _firestore.collection('items').where('categories', arrayContains: category.idx).limit(20);
  // TODO: add where by NOT current user (maybe order by createdAt?)

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get().then((QuerySnapshot itemsQuery) {
    List<Item> list = itemsQuery.docs.map(Item.fromDocumentSnapshot).toList();

    return QueryBatch(list, list.length == 20, itemsQuery.docs.isNotEmpty ? itemsQuery.docs.last : null);
  });
}

Future<List<Item>> getItemsByLocation(Position position, String cityName) async {
  return _getItemsByQuery(_firestore.collection('items').where(
      'location.city', isEqualTo: cityName).get(), true);
}

Future<List<Item>> getItemsByGeoPoint(double minLat, double maxLat, double minLng, double maxLng) async {
  return _getItemsByQuery(_firestore.collection('items').where(
      'location.geoPoint', isGreaterThanOrEqualTo: GeoPoint(minLat, minLng)).where(
      'location.geoPoint', isLessThanOrEqualTo: GeoPoint(maxLat, maxLng)).get(), true);
}

Future<QueryBatch<Item>> getItemsByTitle(String title, [DocumentSnapshot? startAfterDoc]) async {
  Query query = _firestore.collection('items')
      .where('title', isGreaterThanOrEqualTo: title, isLessThan: getNextAlphabeticalString(title))
      .limit(20);
  // TODO: add where by NOT current user (maybe order by createdAt?)

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get().then((QuerySnapshot itemsQuery) {
    List<Item> list = itemsQuery.docs.map(Item.fromDocumentSnapshot).toList();

    return QueryBatch(list, list.length == 20, itemsQuery.docs.isNotEmpty ? itemsQuery.docs.last : null);
  });
}

Future<Item?> getItemById(String id) async {
  return _firestore.collection('items').doc(id).get().then(Item.fromDocumentSnapshot);
}

Future<List<Item>> _getItemsByQuery(Future<QuerySnapshot<Map<String, dynamic>>> query, bool onlyOthersItems) async {
  List<Item> items = [];
  QuerySnapshot getItems = await query;
  var itemsDoc = getItems.docs;
  for (var itemDoc in itemsDoc) {
    Item item = Item.fromDocumentSnapshot(itemDoc);
    if (!onlyOthersItems || item.contactUserID != userDetails.docRef.id) {
      items.add(item);
    }
  }
  return items;
}

Stream<QuerySnapshot<Map<String, dynamic>>> getUserItemsStream() {
  return _firestore.collection('items').where('contactUserID', isEqualTo: userDetails.docRef.id).orderBy('createdAt', descending: true).snapshots();
}

//REQUESTS
Future<List<ItemRequest>> getUserRequestsStream() {
  return _firestore.collection('requests')
      .where('ownerID', isEqualTo: userDetails.docRef.id)
      .orderBy('requestTime', descending: true)
      .get()
      .then((QuerySnapshot query) => query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Future<List<ItemRequest>> getPendingRequestsStream() {
  return _firestore.collection('requests')
      .where('applicantID', isEqualTo: userDetails.docRef.id)
      .orderBy('requestTime', descending: true)
      .get()
      .then((QuerySnapshot query) => query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Stream<List<ItemRequest>> getFutureItemRequestsStream(DocumentReference itemRef) {
  return _firestore.collection('requests')
      .where('itemID', isEqualTo: itemRef.id)
      .where('time.end', isGreaterThan: Timestamp.now())
      .where('status', isNotEqualTo: RequestStatus.REJECTED.index)
      .snapshots()
      .map((QuerySnapshot query) => query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Future<List<ItemRequest>> getFutureItemRequests(String itemID) {
  return _firestore.collection('requests')
      .where('itemID', isEqualTo: itemID)
      .where('time.end', isGreaterThan: Timestamp.now())
      .where('status', isNotEqualTo: RequestStatus.REJECTED.index)
      .get()
      .then((QuerySnapshot query) => query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Stream<ItemRequest> getItemRequestStream(DocumentReference docRef) {
  return docRef.snapshots().map(ItemRequest.fromDocumentSnapshot);
}

void addRequest(Item item, DateTimeRange range){
  _firestore.collection('requests').add({
    'ownerID': item.contactUserID,
    'applicantID': userDetails.docRef.id,
    'itemID': item.docRef.id,
    'status': RequestStatus.WAITING.index,
    'time': {
      'start': range.start,
      'end': range.end
    },
    'price': item.price,
    'pickUpLocation': item.location.toMap(),
    'requestTime': FieldValue.serverTimestamp()
  });
}

void updateRequestStatus(DocumentReference docRef, RequestStatus status){
  docRef.update({'status': status.index});
}

void updateExtensionRequest(DocumentReference docRef, DateTime toDate) {
  docRef.update({'extensionRequest': {
    'toDate': toDate,
    'status': RequestStatus.WAITING.index,
    'requestTime': FieldValue.serverTimestamp()
  }});
}

void removeExtensionRequest(DocumentReference docRef) {
  docRef.update({'extensionRequest': null});
}

void deleteRequest(DocumentReference docRef) {
  docRef.delete();
}

//CHATS

void sendMessage(DocumentReference chatRef, int userIndex, String text, MessageType type, String? fileRef) {
  Map<String, dynamic> messageData = {
    'sender': userIndex,
    'text': text,
    'sentAt': FieldValue.serverTimestamp(),
    'type': type.index,
  };
  if (fileRef != null) {
    messageData['fileRef'] = fileRef;
  }
  chatRef.collection('messages').add(messageData);
  chatRef.update({'lastMessageSentAt': FieldValue.serverTimestamp()});
}

Future<void> sendImageMessage(DocumentReference chatRef, int userIndex, File image) async {
  WriteBatch batch = _firestore.batch();

  DocumentReference messageRef = chatRef.collection('messages').doc();

  await uploadImage(storageRef.child('messages').child('${messageRef.id}.jpg'), image);

  Map<String, dynamic> messageData = {
    'sender': userIndex,
    'text': 'תמונה',
    'sentAt': FieldValue.serverTimestamp(),
    'type': MessageType.IMAGE.index,
  };

  batch.set(messageRef, messageData);
  batch.update(chatRef, {'lastMessageSentAt': FieldValue.serverTimestamp()});

  batch.commit();
}

Future<Chat> sendItemMessage(String userID, DocumentReference itemRef) async {
  Chat? chat;
  QuerySnapshot usersChatsQuery = await _firestore.collection('chats')
      .where('participants.${userDetails.docRef.id}', isNull: false)
      .get();
  chat = usersChatsQuery.docs.map(Chat.fromDocumentSnapshot).where((chat) => chat.participants.containsKey(userID)).firstOrNull;
  if (chat == null) {
    DocumentReference chatDoc = await _firestore.collection('chats').add({
      'lastMessageSentAt': FieldValue.serverTimestamp(),
      'participants': {
        userDetails.docRef.id: {'index': 0, 'lastMessageSeenTime': FieldValue.serverTimestamp()},
        userID: {'index': 1, 'lastMessageSeenTime': Timestamp.fromMillisecondsSinceEpoch(0)},
      }
    });
    DocumentSnapshot chatSnapshot = await chatDoc.get();
    chat = Chat.fromDocumentSnapshot(chatSnapshot);
  }
  int userIndex = chat.participants[userDetails.docRef.id]?.index ?? -1;
  if (userIndex == 0 || userIndex == 1) {
    await chat.docRef.collection('messages').add({
      'sender': userIndex,
      'text': 'האם ניתן להשכיר פריט זה?',
      'sentAt': FieldValue.serverTimestamp(),
      'type': MessageType.ITEM.index,
      'fileRef': itemRef.id
    });
    await chat.docRef.update({'lastMessageSentAt': FieldValue.serverTimestamp()});
  }
  return chat;
}

Future<void> updateUserLastMessageSeenTime(DocumentReference chatRef, DateTime dateTime) {
  return chatRef.update({
    'participants.${userDetails.docRef.id}.lastMessageSeenTime': Timestamp.fromDate(dateTime)
  });
}

Stream<List<Chat>> getUserChatsStream(){
  return _firestore
      .collection('chats')
      .where('participants.${userDetails.docRef.id}', isNull: false)
      // .orderBy('lastMessageSentAt', descending: true)
      .snapshots()
      .map((QuerySnapshot query) => query.docs.map(Chat.fromDocumentSnapshot).toList());
}

Stream<Chat> getChatStream(DocumentReference chatRef) {
  return chatRef.snapshots().map(Chat.fromDocumentSnapshot);
}

Future<Chat> getChatFromChatID(String chatID) async {
  return _firestore.collection('chats').doc(chatID).get().then(Chat.fromDocumentSnapshot);
}

Future<String> getOtherParticipantName(Chat chat) async {
  for (String uid in chat.participants.keys) {
    if (uid != userDetails.docRef.id) {
      UserDetails otherParticipantUser = await getUserByID(uid);
      return otherParticipantUser.name;
    }
  }
  return '';
}

//MESSAGES

Stream<Message?> getLastMessageStream(DocumentReference chatRef) {
  return chatRef
      .collection('messages')
      .orderBy('sentAt', descending: true)
      .limit(1)
      .snapshots()
      .map((QuerySnapshot query) => query.docs.map((doc) => mapAsMessage(doc.data() as Map<String, dynamic>, doc.reference)).toList().firstOrNull);
}

Future<QuerySnapshot> getHistoricalMessages(DocumentReference chatRef, int limit, DocumentSnapshot? startAfterDoc) {
  Query query = chatRef.collection('messages').orderBy('sentAt', descending: true).limit(limit);

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get();
}

Stream<QuerySnapshot<Map<String, dynamic>>> getNewMessagesStream(DocumentReference chatRef) {
  return chatRef.collection('messages').orderBy('sentAt').where('sentAt', isGreaterThan: DateTime.now()).snapshots();
}

Reference getMessageImageRef(DocumentReference messageRef) {
  return storageRef.child('messages').child('${messageRef.id}.jpg');
}

//REVIEWS

void addItemReview(DocumentReference itemRef, int? overallRate, int? valueForPrice, int? compatibility, Condition? condition, String? text) {
  WriteBatch batch = _firestore.batch();
  batch.set(itemRef.collection('reviews').doc(), {
    'userID': userDetails.docRef.id,
    if(overallRate != null) 'overallRate': overallRate,
    if(valueForPrice != null) 'valueForPrice': valueForPrice,
    if(compatibility != null) 'compatibility': compatibility,
    if(text != null) 'text': text,
    if(condition != null) 'condition': condition.idx,
    'createdAt': FieldValue.serverTimestamp()
  });
  if(overallRate != null) {
    batch.update(
        itemRef, {'overallRateCount': FieldValue.increment(1), 'overallRateSum': FieldValue.increment(overallRate)});
  }
  batch.commit();
}

Future<List<ItemReview>> getItemReviews(DocumentReference itemRef) async {
  return await itemRef.collection('reviews').where('text', isNull: false).orderBy('createdAt', descending: true).get().then((QuerySnapshot query) => query.docs.map(ItemReview.fromDocumentSnapshot).toList());
}

void addUserReview(DocumentReference userRef, int? overallRate, int? serviceLevel, String? text) {
  WriteBatch batch = _firestore.batch();
  batch.set(userRef.collection('reviews').doc(), {
    'userID': userDetails.docRef.id,
    if(overallRate != null) 'overallRate': overallRate,
    if(serviceLevel != null) 'valueForPrice': serviceLevel,
    if(text != null) 'text': text,
    'createdAt': FieldValue.serverTimestamp()
  });
  if(overallRate != null) {
    batch.update(
        userRef, {'overallRateCount': FieldValue.increment(1), 'overallRateSum': FieldValue.increment(overallRate)});
  }
  batch.commit();
}

Future<List<UserReview>> getUserReviews(DocumentReference userRef) async {
  return await userRef.collection('reviews').orderBy('createdAt', descending: true).get().then((QuerySnapshot query) => query.docs.map(UserReview.fromDocumentSnapshot).toList());
}

Future<int> getTextItemReviewsCount(DocumentReference itemRef) async {
  int reviewsCount = 0;
  await itemRef.collection('reviews').where('text', isNull: false).count().get().then(
        (res) => reviewsCount = res.count!,
  );
  return reviewsCount;
}

// Future<void> addRateField() async {
//   var snapshot = await _firestore.collection('items').get();
//   WriteBatch batch = _firestore.batch();
//   for (var doc in snapshot.docs) {
//     // batch.update(doc.reference, {'mainImage': '0.jpg'});
//
//     // Step 1: Download the file data from the original path
//     final oldFileRef = storageRef.child(doc.reference.id);
//     Uint8List? fileData;
//     try {
//       fileData = await oldFileRef.getData();
//     } catch (e) {
//       print('Failed to retrieve file path: ${doc.reference.id}');
//     }
//
//     if (fileData != null) {
//       // Step 2: Upload the file data to the new path
//       final newFileRef = storageRef.child('items').child(doc.reference.id).child('0.jpg');
//       await newFileRef.putData(fileData);
//
//       print('File copied successfully: ${doc.reference.id}');
//     } else {
//       print('Failed to retrieve file data: ${doc.reference.id}');
//     }
//
//   }
//   try {
//     // await batch.commit();
//     print('All documents updated successfully!');
//   } catch (e) {
//     print('Error updating documents: $e');
//   }
// }

//AUTH

Future<void> login(String email, String password) async {
  final user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password);
  userUid = user.user?.uid;
}

User? getCurrentUser() {
  try {
    return _auth.currentUser;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<UserDetails> getUser() async {
  userDetails = await getUserByID(userUid!);
  return userDetails;
}

Future<void> createNewUser(String email, String password, String name, String phoneNumber) async{
  final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  userUid = newUser.user?.uid;
  DocumentReference userRef = _firestore.collection('users').doc(userUid);
  userDetails = UserDetails(
      docRef: userRef,
      name: name,
      phoneNumber: int.parse(phoneNumber),
  );
  setToken();
}

void signOut(){
  _auth.signOut();
}

//USERS
Future<UserDetails> getUserByID(String id) async {
  return _firestore.collection('users').doc(id).get().then(UserDetails.fromDocumentSnapshot);
}

Future<QueryBatch<Item>> getUserSeenItems([DocumentSnapshot? startAfterDoc]) {
  return _getUserItems('seen', 'seenTime', startAfterDoc);
}

Future<QueryBatch<Item>> getUserFavoriteItems([DocumentSnapshot? startAfterDoc]) {
  return _getUserItems('favorites', 'updateTime', startAfterDoc);
}

Future<QueryBatch<Item>> _getUserItems(String collectionName, String orderByFieldName, DocumentSnapshot? startAfterDoc) {
  Query query = userDetails.docRef.collection(collectionName).orderBy(orderByFieldName, descending: true).limit(20);

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get().then((QuerySnapshot itemIdsQuery) {
    List<String> itemIds = itemIdsQuery.docs.map((QueryDocumentSnapshot snapshot) => snapshot.id).toList();

    return _firestore
        .collection('items')
        .where(FieldPath.documentId, whereIn: itemIds)
        .get()
        .then((QuerySnapshot itemsQuery) {
      List<Item> items = itemsQuery.docs.map(Item.fromDocumentSnapshot).toList();

      Map<String, Item> itemMap = {for (Item item in items) item.docRef.id: item};

      List<Item?> list = itemIds.map((String id) => itemMap[id]).toList();
      list.removeWhere((item) => item == null);

      return QueryBatch(list.cast<Item>(), itemIds.length == 20, itemIdsQuery.docs.isNotEmpty ? itemIdsQuery.docs.last : null);
    });
  });
}

Stream<bool> getUserFavoriteItem(DocumentReference itemRef) {
  return userDetails.docRef.collection('favorites').doc(itemRef.id).snapshots().map((DocumentSnapshot snapshot) => snapshot.exists);
}

Future<void> updateUserItemSeen(DocumentReference itemRef) async {
  var batch = _firestore.batch();
  DocumentSnapshot snapshot = await userDetails.docRef.collection('seen').doc(itemRef.id).get();
  if (!snapshot.exists) {
    batch.update(itemRef, {'seenCount': FieldValue.increment(1)});
  }
  batch.set(userDetails.docRef.collection('seen').doc(itemRef.id), {'seenTime': FieldValue.serverTimestamp()});
  return batch.commit();
}

Future<void> deleteOldUserItemSeen(DateTime dateTime) async {
  QuerySnapshot querySnapshot = await userDetails.docRef.collection('seen')
      .where('seenTime', isLessThan: dateTime)
      .limit(100)
      .get();

  for (final doc in querySnapshot.docs) {
    await doc.reference.delete();
  }
}

Future<void> toggleUserFavoriteItem(DocumentReference itemRef) async {
  var batch = _firestore.batch();
  DocumentSnapshot snapshot = await userDetails.docRef.collection('favorites').doc(itemRef.id).get();
  if (snapshot.exists) {
    batch.delete(snapshot.reference);
    batch.update(itemRef, {'favoriteCount': FieldValue.increment(-1)});
  } else {
    batch.set(snapshot.reference, {'updateTime': FieldValue.serverTimestamp()});
    batch.update(itemRef, {'favoriteCount': FieldValue.increment(1)});
  }
  return batch.commit();
}

//Messaging
void requestNotificationsPermission() async {
  NotificationSettings settings = await _messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

void setToken(){
  _messaging.getToken().then((String? token) {
    if (token != null && token != userDetails.token) {
      userDetails.token = token;
      userDetails.docRef.update({'token': token});
    }
  });
}

void onTokenRefreshed(){
  _messaging.onTokenRefresh.listen((newToken) {
    userDetails.token = newToken;
    userDetails.docRef.update({
      'token': newToken,
    });
  });
}

void messagingListenForeground(){
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null && activeChatId != message.data['chatId']) {
      // showNotification(message.notification!.title, message.notification!.body, message);
    }
  });
}

void onMessageOpenedApp(BuildContext context){
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleNotificationTap(context, message.data);
  });
}

Future<void> messagingHandlerBackground(RemoteMessage message)async{
  if (message.notification != null) {
    // showNotification(message.notification!.title, message.notification!.body, message);
  }
}
