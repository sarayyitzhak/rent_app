import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/user.dart';
import '../models/address_info.dart';
import '../models/category.dart';
import '../models/chat.dart';
import '../models/request.dart';

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
      imageRef: '',
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
  newItem.imageRef = imageDownloadUrl;
  itemDoc.set(newItem.itemToMap());

  userDetails.userReference.update({'items': FieldValue.arrayUnion([itemDoc])});
}

Future<List<Item>> getItemsByCategory(ItemCategory category) async {
  return _getItemsByQuery(_firestore.collection('items').where(
      'categories', arrayContains: category.idx).get(), true);
}

Future<List<Item>> getItemsByLocation(Position position, String cityName) async {
  return _getItemsByQuery(_firestore.collection('items').where(
      'location.city', isEqualTo: cityName).get(), true);
}

Future<List<Item>> getItemsByContactUser(DocumentReference contactUser) async {
  return _getItemsByQuery(_firestore.collection('items').where(
      'contactUser', isEqualTo: contactUser).orderBy('createdAt', descending: true).get(), false);
}

Future<List<Item>> getItemsByTitle(String title) async {
  return _getItemsByQuery(_firestore.collection('items').where('title', isEqualTo: title).get(), false);
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
  for (DocumentReference itemRef in itemsRefs) {
    var itemGetData = await itemRef.get();
    if (itemGetData.exists) {
      Map<String, dynamic>? itemData = itemGetData.data()! as Map<String, dynamic>?;
      Item item = mapAsItem(itemData!, itemRef);
      if (item.contactUser != userDetails.userReference ) {
        items.add(item);
      }
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
      var item = mapAsItem(itemData, itemDoc.reference);
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
  return _firestore.collection('requests').where('ownerID', isEqualTo: userDetails.userReference.id).orderBy('requestTime').get();
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

Future<Chat> createNewChat(DocumentReference contactUser) async {
  DocumentReference chatDoc = _firestore.collection('chats').doc();
  Chat chat = Chat(participants: [userDetails.userReference, contactUser], cloudKey: chatDoc);
  userDetails.userReference.update({'chats': FieldValue.arrayUnion([chatDoc])});
  contactUser.update({'chats': FieldValue.arrayUnion([chatDoc])});
  userDetails.chats.add(chatDoc);
  chatDoc.set({'participants': [userDetails.userReference, contactUser]});
  // chatDoc.collection('messages').add({//do it after first message is sent
  //   'sender': 1,
  //   'text': 'hi how are you',
  //   'sentAt': Timestamp.now(),
  //   'read': true,
  // });
  // Chat chat = Chat()..participants = participants.map((p) => p.path).toList()..cloudKey = chatDoc.id;
  // await isar.writeTxn(() async {
  //   await isar.chats.put(chat);
  // });
  return chat;
}

Future<Chat?> getChat(DocumentReference contactUser) async {
  var usersChats = await _firestore.collection('chats').where('participants', arrayContains: userDetails.userReference).get();
  for (var chat in usersChats.docs) {
    Map<String, dynamic> chatData = chat.data();
    List<DocumentReference> participants = (chatData['participants'] as List<dynamic>).map((e) => e as DocumentReference).toList();
    if (participants[0] == contactUser || participants[1] == contactUser) {
      return Chat(participants: participants, cloudKey: chat.reference);
    }
    // var c = await isar.chats.filter().participantsElementContains(userDetails.userReference.path).participantsElementContains(widget.item.contactUser.path).findFirst();
    // return c;

    // List participants = await isar.chats.filter().participantsElementContains(widget.item.contactUser.id).findAll();//user is in the participants
    // if(participants.isNotEmpty){
    //go to chat
    // } else {
    //create chat
    // }
    // CollectionReference chatsRef = _firestore.collection('chats'); // maybe better somehow
    // var chat = chatsRef.where('participants', arrayContains: [userDetails.userReference, widget.item.contactUser]);
    //
    // for(DocumentReference chat in userDetails.chats){
    //   var chatDoc = await chat.get();
    //   var chatData = chatDoc.data() as Map<String, dynamic>;
    //   participants = chatData['participants'];
    //   if(participants.contains(widget.item.contactUser)){
    //     return chatData;
    //   }
    // }
    // return null;
  }
  return null;
}

Stream<QuerySnapshot<Map<String, dynamic>>> getUserChatsStream(){
  return _firestore.collection('chats').where('participants', arrayContains: userDetails.userReference).orderBy('lastMessageSentAt').snapshots();
}

//AUTH
User? getCurrentUser() {
  try {
    return _auth.currentUser;
  } catch (e) {
    print(e);
  }
  return null;
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
  _messaging.getToken().then((String? token) {
    if (token != null) {
      userDetails.token = token;
    }
  });
  userReference.set(userDetails.userAsMap());
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
