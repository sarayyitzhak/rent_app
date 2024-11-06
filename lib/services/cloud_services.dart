import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_review.dart';
import 'package:rent_app/models/message.dart';
import 'package:rent_app/models/user.dart';
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


//ITEMS
Future<void> createNewItem(File? image, String title, String price, AddressInfo addressValue, String description, Condition condition, List<dynamic> categories) async {
  var itemDoc = _firestore.collection('items').doc();
  final itemRef = storageRef.child(itemDoc.id);
  UploadTask uploadTask = itemRef.putFile(image!);
  TaskSnapshot taskSnapshot = await uploadTask;
  var imageDownloadUrl = await taskSnapshot.ref.getDownloadURL();

  Item newItem = Item(
      itemReference: itemDoc,
      contactUser: userDetails.docRef,
      imageRef: imageDownloadUrl,
      title: title,
      price: int.parse(price),
      location: addressValue,
      description: description,
      condition: condition,
      categories: categories,
      createdAt: Timestamp.now(),
      favoriteCount: 0,
      seenCount: 0,
  );
  itemDoc.set(newItem.itemToMap());

  userDetails.docRef.update({'items': FieldValue.arrayUnion([itemDoc])});
}

Future<void> editItem(Item item, bool isImageChanged, File? image, String title, String price, AddressInfo addressValue, String description, Condition condition, List<dynamic> categories) async {
  if(isImageChanged){
    final itemRef = storageRef.child('${item.itemReference.id}/${Timestamp.now()}');
    UploadTask uploadTask = itemRef.putFile(image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    item.imageRef = await taskSnapshot.ref.getDownloadURL();
  }
  item.title = title;
  item.price = int.parse(price);
  item.location = addressValue;
  item.description = description;
  item.condition = condition;
  item.categories = categories;
  _firestore.collection('items').doc(item.itemReference.id).update(item.itemToMap());
}

Future<List<Item>> getItemsByCategory(ItemCategory category) async {
  return _getItemsByQuery(_firestore.collection('items').where(
      'categories', arrayContains: category.idx).get(), true);
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

Future<List<Item>> getItemsByContactUser(DocumentReference contactUser) async {
  return _getItemsByQuery(_firestore.collection('items').where(
      'contactUser', isEqualTo: contactUser).orderBy('createdAt', descending: true).get(), false);
}

Future<List<Item>> getItemsByTitle(String title) async {
  return _getItemsByQuery(_firestore.collection('items')
      .where('title', isGreaterThanOrEqualTo: title)
      .where('title', isLessThan: getNextAlphabeticalString(title))
      .get(), false);
}

Future<Item?> getItemById(String id) async {
  DocumentSnapshot<Map<String, dynamic>> itemSnapshot = await _firestore.collection('items').doc(id).get();
  Map<String, dynamic>? data = itemSnapshot.data();
  return data != null ? mapAsItem(data, itemSnapshot.reference) : null;
}

Future<List<Item>> _getItemsByQuery(Future<QuerySnapshot<Map<String, dynamic>>> query, bool onlyOthersItems) async {
  List<Item> items = [];
  QuerySnapshot<Map<String, dynamic>> getItems = await query;
  var itemsDoc = getItems.docs;
  if (itemsDoc.isNotEmpty) {
    for (var itemDoc in itemsDoc) {
      Map<String, dynamic>? itemData = itemDoc.data();
      Item item = mapAsItem(itemData, itemDoc.reference);
      if (!onlyOthersItems || item.contactUser != userDetails.docRef) {
        items.add(item);
      }
    }
  }
  return items;
}

Stream<QuerySnapshot<Map<String, dynamic>>> getUserItemsStream() {
  return _firestore.collection('items').where('contactUser', isEqualTo: userDetails.docRef).orderBy('createdAt', descending: true).snapshots();
}

//REQUESTS
Future<List<ItemRequest>> getUserRequestsStream() {
  return _firestore.collection('requests')
      .where('ownerID', isEqualTo: userDetails.docRef.id)
      .orderBy('requestTime', descending: true)
      .get()
      .then((QuerySnapshot query) => query.docs.map((QueryDocumentSnapshot snapshot) => ItemRequest.fromDocumentSnapshot(snapshot)).toList());
}

Future<List<ItemRequest>> getPendingRequestsStream() {
  return _firestore.collection('requests')
      .where('applicantID', isEqualTo: userDetails.docRef.id)
      .orderBy('requestTime', descending: true)
      .get()
      .then((QuerySnapshot query) => query.docs.map((QueryDocumentSnapshot snapshot) => ItemRequest.fromDocumentSnapshot(snapshot)).toList());
}

Stream<List<ItemRequest>> getFutureItemRequestsStream(DocumentReference itemRef) {
  return _firestore.collection('requests')
      .where('itemID', isEqualTo: itemRef.id)
      .where('time.end', isGreaterThan: Timestamp.now())
      .where('status', isNotEqualTo: RequestStatus.REJECTED.index)
      .snapshots()
      .map((QuerySnapshot query) => query.docs.map((QueryDocumentSnapshot snapshot) => ItemRequest.fromDocumentSnapshot(snapshot)).toList());
}

Future<List<ItemRequest>> getFutureItemRequests(String itemID) {
  return _firestore.collection('requests')
      .where('itemID', isEqualTo: itemID)
      .where('time.end', isGreaterThan: Timestamp.now())
      .where('status', isNotEqualTo: RequestStatus.REJECTED.index)
      .get()
      .then((QuerySnapshot query) => query.docs.map((QueryDocumentSnapshot snapshot) => ItemRequest.fromDocumentSnapshot(snapshot)).toList());
}

Stream<ItemRequest> getItemRequestStream(DocumentReference docRef) {
  return docRef
      .snapshots()
      .map((DocumentSnapshot snapshot) => ItemRequest.fromDocumentSnapshot(snapshot));
}

void addRequest(Item item, DateTimeRange range){
  _firestore.collection('requests').add({
    'ownerID': item.contactUser.id,
    'applicantID': userDetails.docRef.id,
    'itemID': item.itemReference.id,
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

Future<Chat> sendItemMessage(DocumentReference userRef, DocumentReference itemRef) async {
  Chat? chat;
  QuerySnapshot usersChatsQuery = await _firestore.collection('chats')
      .where('participants.${userDetails.docRef.id}', isNull: false)
      .get();
  chat = usersChatsQuery.docs.map((doc) => Chat.fromDocumentSnapshot(doc)).where((chat) => chat.participants.containsKey(userRef.id)).firstOrNull;
  if (chat == null) {
    DocumentReference chatDoc = await _firestore.collection('chats').add({
      'lastMessageSentAt': FieldValue.serverTimestamp(),
      'participants': {
        userDetails.docRef.id: {'index': 0, 'lastMessageSeenTime': FieldValue.serverTimestamp()},
        userRef.id: {'index': 1, 'lastMessageSeenTime': Timestamp.fromMillisecondsSinceEpoch(0)},
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
      .map((QuerySnapshot query) => query.docs.map((doc) => Chat.fromDocumentSnapshot(doc)).toList());
}

Stream<Chat> getChatStream(DocumentReference chatRef) {
  return chatRef.snapshots().map((DocumentSnapshot snapshot) => Chat.fromDocumentSnapshot(snapshot));
}

Future<Chat> getChatFromChatID(String chatID) async {
  DocumentSnapshot<Map<String, dynamic>> chatDoc = await _firestore.collection('chats').doc(chatID).get();
  return Chat.fromDocumentSnapshot(chatDoc);
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

//REVIEWS

void addItemReview(DocumentReference itemRef, int rate, String text) {
  WriteBatch batch = _firestore.batch();
  batch.set(itemRef.collection('reviews').doc(), {
    'userID': userDetails.docRef.id,
    'rate': rate,
    'text': text,
    'createdAt': FieldValue.serverTimestamp()
  });
  batch.update(itemRef, {'reviewCount': FieldValue.increment(1), 'rateSum': FieldValue.increment(rate)});
  batch.commit();
}

Future<List<ItemReview>> getItemReviews(DocumentReference itemRef) async {
  return await itemRef.collection('reviews').orderBy('createdAt', descending: true).get().then((QuerySnapshot query) => query.docs.map((doc) => ItemReview.fromDocumentSnapshot(doc)).toList());
}

// Future<void> addRateField() async {
//   var snapshot = await _firestore.collection('items').get();
//   WriteBatch batch = _firestore.batch();
//   for (var doc in snapshot.docs) {
//     batch.update(doc.reference, {'rate': 0});
//   }
//   try {
//     await batch.commit();
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
  await getUser();
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
      List<Item> items = itemsQuery.docs
          .map((QueryDocumentSnapshot snapshot) => mapAsItem(snapshot.data() as Map<String, dynamic>, snapshot.reference))
          .toList();

      Map<String, Item> itemMap = {for (Item item in items) item.itemReference.id: item};

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
    FirebaseFirestore.instance.collection('users').doc(userUid).update({
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
