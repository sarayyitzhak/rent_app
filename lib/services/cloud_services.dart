import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/message.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/utils.dart';
import '../models/address_info.dart';
import '../models/category.dart';
import '../models/chat.dart';
import '../models/message_type.dart';
import '../models/request.dart';
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
      contactUser: userDetails.userReference,
      imageRef: imageDownloadUrl,
      title: title,
      price: int.parse(price),
      location: addressValue,
      description: description,
      condition: condition,
      categories: categories,
      createdAt: Timestamp.now(),
      likesCount: 0,
      seenCount: 0
  );
  itemDoc.set(newItem.itemToMap());

  userDetails.userReference.update({'items': FieldValue.arrayUnion([itemDoc])});
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

Future<List<Item>> getItemsListByField(UserDetails user, String dataField, bool reversed) async {
  List<Item> items = [];
  DocumentSnapshot<Object?> userGetData = await user.userReference.get();
  Map<String, dynamic>? userData = userGetData.data() as Map<String, dynamic>?;
  List itemsRefs = userData?[dataField];
  List lastSeenItems = itemsRefs.length > 20 ? itemsRefs.sublist(itemsRefs.length - 20) : itemsRefs;
  QuerySnapshot<Map<String, dynamic>> itemsRefs2 = await _firestore.collection('items').where(FieldPath.documentId, whereIn: lastSeenItems.map((e) => e.id).toList()).get();
  for(var itemDoc in itemsRefs2.docs){
    Map<String, dynamic>? itemData = itemDoc.data();
    Item item = mapAsItem(itemData, itemDoc.reference);
    if (item.contactUser != userDetails.userReference) {
      items.add(item);
    }
  }
  return reversed ? items.reversed.toList() : items;
}

Future<List<Item>> _getItemsByQuery(Future<QuerySnapshot<Map<String, dynamic>>> query, bool onlyOthersItems) async {
  List<Item> items = [];
  QuerySnapshot<Map<String, dynamic>> getItems = await query;
  var itemsDoc = getItems.docs;
  if (itemsDoc.isNotEmpty) {
    for (var itemDoc in itemsDoc) {
      Map<String, dynamic>? itemData = itemDoc.data();
      Item item = mapAsItem(itemData, itemDoc.reference);
      if (!onlyOthersItems || item.contactUser != userDetails.userReference) {
        items.add(item);
      }
    }
  }
  return items;
}

Stream<QuerySnapshot<Map<String, dynamic>>> getUserItemsStream() {
  return _firestore.collection('items').where('contactUser', isEqualTo: userDetails.userReference).orderBy('createdAt', descending: true).snapshots();
}

//REQUESTS
Future<QuerySnapshot<Map<String, dynamic>>> getUserRequestsStream() {
  return _firestore.collection('requests').where('ownerID', isEqualTo: userDetails.userReference.id).orderBy('requestTime', descending: true).get();
}

void addRequest(ItemRequest request){
  _firestore.collection('requests').add(request.toMap());
}

void updateRequestStatus(ItemRequest request){
  _firestore.collection('requests').doc(request.cloudKey).update(request.toMap());
}

Future<List<ItemRequest>> getRequestsByFuture(Future<QuerySnapshot<Map<String, dynamic>>> future) async {
  List<ItemRequest> requests = [];
  var requestDocs = await future;
  for(var requestDoc in requestDocs.docs){
    ItemRequest request = mapToItemRequest(requestDoc.data(), requestDoc.id);
    var itemRef = _firestore.collection('items').doc(request.itemID);
    var itemDoc = await itemRef.get();
    request.item = mapAsItem(itemDoc.data()!, itemRef);
    requests.add(request);
  }
  return requests;
}

Future<QuerySnapshot<Map<String, dynamic>>> getPendingRequestsStream() {
  return _firestore.collection('requests').where('applicantID', isEqualTo: userDetails.userReference.id).get();
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
      .where('participants.${userDetails.userReference.id}', isNull: false)
      .get();
  chat = usersChatsQuery.docs.map((doc) => Chat.fromDocumentSnapshot(doc)).where((chat) => chat.participants.containsKey(userRef.id)).firstOrNull;
  if (chat == null) {
    DocumentReference chatDoc = await _firestore.collection('chats').add({
      'lastMessageSentAt': FieldValue.serverTimestamp(),
      'participants': {
        userDetails.userReference.id: {'index': 0, 'lastMessageSeenTime': FieldValue.serverTimestamp()},
        userRef.id: {'index': 1, 'lastMessageSeenTime': Timestamp.fromMillisecondsSinceEpoch(0)},
      }
    });
    DocumentSnapshot chatSnapshot = await chatDoc.get();
    chat = Chat.fromDocumentSnapshot(chatSnapshot);
  }
  int userIndex = chat.participants[userDetails.userReference.id]?.index ?? -1;
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
    'participants.${userDetails.userReference.id}.lastMessageSeenTime': Timestamp.fromDate(dateTime)
  });
}

Stream<List<Chat>> getUserChatsStream(){
  return _firestore
      .collection('chats')
      .where('participants.${userDetails.userReference.id}', isNull: false)
      // .orderBy('lastMessageSentAt', descending: true)
      .snapshots()
      .map((QuerySnapshot query) => query.docs.map((doc) => Chat.fromDocumentSnapshot(doc)).toList());
}

Stream<Chat> getChatStream(DocumentReference chatRef) {
  return chatRef.snapshots().map((DocumentSnapshot snapshot) => Chat.fromDocumentSnapshot(snapshot));
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
  userDetails = await getUserDetailsByUid(userUid!);
  return userDetails;
}

Future<void> createNewUser(String email, String password, String name, String phoneNumber) async{
  final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  userUid = newUser.user?.uid;
  DocumentReference userReference =
  _firestore.collection('users').doc(userUid);
  userDetails = UserDetails(
      userReference: userReference,
      name: name,
      email: email,
      phoneNumber: int.parse(phoneNumber),
      items: [],
      wishlist: [],
      seen: [],
      chats: []
  );
  setToken();
}

void signOut(){
  _auth.signOut();
}

//USERS
Future<UserDetails> getUserDetailsByUid(String userUid) async{
  var userDoc =  await _firestore.collection('users').doc(userUid).get();
  return mapAsUser(userDoc.data() as Map<String, dynamic>);
}

Future<UserDetails> getItemContactUser(Item item) async {
  var contactUserDoc = await item.contactUser.get();
  Map<String, dynamic>? contactUserData = contactUserDoc.data() as Map<String, dynamic>?;
  return mapAsUser(contactUserData!);
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
    if (token != null) {
      userDetails.token = token;
      userDetails.userReference.update({'token': token});
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
    if (message.notification != null && !isChatScreenActive) {
      showNotification(message.notification!.title, message.notification!.body);
    }
  });
}

Future<void> messagingHandlerBackground(RemoteMessage message)async{
  if (message.notification != null) {
    showNotification(message.notification!.title, message.notification!.body);
  }
}
