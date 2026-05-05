import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/file_data.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_review.dart';
import 'package:rent_app/models/message.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/models/user_review.dart';
import 'package:rent_app/services/bounding_boxing_query.dart';
import 'package:rent_app/services/query_batch.dart';
import 'package:rent_app/utils.dart';
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

//FILES

Future<Uint8List?> readFile(Reference fileRef,
    [String fileExtension = 'jpg']) async {
  Uint8List? data = await fileRef.getData();
  if (data != null) {
    DefaultCacheManager().putFile(fileRef.fullPath, data,
        key: fileRef.fullPath, fileExtension: fileExtension);
  }
  return data;
}

Future<List<Reference>> getFileReferences(Reference dirRef) async {
  return dirRef.listAll().then((ListResult res) => res.items);
}

Future<UploadTask> uploadFile(Reference fileRef, File file,
    [String fileExtension = 'jpg']) async {
  await DefaultCacheManager().putFile(fileRef.fullPath, file.readAsBytesSync(),
      key: fileRef.fullPath, fileExtension: fileExtension);
  return fileRef.putFile(file);
}

Future<UploadTask> uploadData(Reference fileRef, Uint8List data,
    [String fileExtension = 'jpg']) async {
  await DefaultCacheManager().putFile(fileRef.fullPath, data,
      key: fileRef.fullPath, fileExtension: fileExtension);
  return fileRef.putData(data);
}

Future<UploadTask> uploadFileData(Reference dirRef, FileData fileData) async {
  return uploadData(
      dirRef.child(fileData.fullName), fileData.data, fileData.extension);
}

Future<void> deleteFile(Reference fileRef) async {
  await DefaultCacheManager().removeFile(fileRef.fullPath);
  return fileRef.delete();
}

//ITEMS
Future<void> createNewItem(
    List<FileData> imageDataList,
    String mainImage,
    List<String> images,
    String title,
    String price,
    GeoPoint geoPoint,
    String description,
    Condition condition,
    List<ItemCategory> categories) async {
  DocumentReference itemRef = _firestore.collection('items').doc();
  for (FileData fileData in imageDataList) {
    await uploadFileData(getItemImageDirRef(itemRef), fileData);
  }

  return itemRef.set({
    'contactUserID': userDetails.docRef.id,
    'mainImage': mainImage,
    if (images.isNotEmpty) 'images': images,
    'title': title,
    'price': int.parse(price),
    'latitude': geoPoint.latitude,
    'longitude': geoPoint.longitude,
    'description': description,
    'condition': condition.index,
    'categories': categories.map((c) => c.index).toList(),
    'createdAt': FieldValue.serverTimestamp(),
    'favoriteCount': 0,
    'seenCount': 0,
  });
}

Future<void> editItem(
    Item item,
    String mainImage,
    List<String> images,
    String title,
    int price,
    GeoPoint geoPoint,
    String description,
    Condition condition,
    List<ItemCategory> categories) async {
  Map<String, Object> data = {
    if (item.mainImage != mainImage) 'mainImage': mainImage,
    if (images.isNotEmpty && !areListsEqual(item.images, images))
      'images': images,
    if (images.isEmpty) 'images': FieldValue.delete(),
    if (item.title != title) 'title': title,
    if (item.price != price) 'price': price,
    if (item.geoPoint.latitude != geoPoint.latitude)
      'latitude': geoPoint.latitude,
    if (item.geoPoint.longitude != geoPoint.longitude)
      'longitude': geoPoint.longitude,
    if (item.description != description) 'description': description,
    if (item.condition != condition) 'condition': condition.index,
    if (!areListsEqual(item.categories, categories))
      'categories': categories.map((c) => c.idx).toList(),
  };
  return data.isNotEmpty ? item.docRef.update(data) : Future.value();
}

Reference getItemImageDirRef(DocumentReference itemRef) {
  return storageRef.child('items').child(itemRef.id);
}

Reference getItemImageRef(DocumentReference itemRef, String imageName) {
  return getItemImageDirRef(itemRef).child('$imageName.jpg');
}

Future<QueryBatch<Item>> getItemsByCategory(ItemCategory category,
    [DocumentSnapshot? startAfterDoc]) async {
  Query query = _firestore
      .collection('items')
      .where('categories', arrayContains: category.idx)
      .limit(20);
  // TODO: add where by NOT current user (maybe order by createdAt?)

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get().then((QuerySnapshot itemsQuery) {
    List<Item> list = itemsQuery.docs.map(Item.fromDocumentSnapshot).toList();

    return QueryBatch(list, list.length == 20, itemsQuery.docs.lastOrNull);
  });
}

Future<BoundingBoxingQuery> getItemsByGeoPoint(GeoPoint centerGeoPoint,
    [int distance = BoundingBoxingQuery.kDistanceStep,
    DocumentSnapshot? startAfterDoc]) async {
  List<Item> items = [];

  while (distance < BoundingBoxingQuery.kMaxDistance) {
    List<GeoPoint> outerSquare = getSquare(centerGeoPoint, distance);

    Query query = _firestore
        .collection('items')
        .orderBy('latitude')
        .orderBy('longitude')
        .orderBy('contactUserID')
        .where('contactUserID', isNotEqualTo: userDetails.docRef.id)
        .where('latitude', isGreaterThanOrEqualTo: outerSquare[0].latitude)
        .where('longitude', isGreaterThanOrEqualTo: outerSquare[0].longitude)
        .where('latitude', isLessThanOrEqualTo: outerSquare[1].latitude)
        .where('longitude', isLessThanOrEqualTo: outerSquare[1].longitude);

    if (distance > BoundingBoxingQuery.kDistanceStep) {
      List<GeoPoint> innerSquare = getSquare(
          centerGeoPoint, distance - BoundingBoxingQuery.kDistanceStep);

      query = query.where(Filter.or(
          Filter.or(Filter('latitude', isGreaterThan: innerSquare[1].latitude),
              Filter('latitude', isLessThan: innerSquare[0].latitude)),
          Filter.or(
              Filter('longitude', isGreaterThan: innerSquare[1].longitude),
              Filter('longitude', isLessThan: innerSquare[0].longitude))));
    }

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    int limit = 20 - items.length;
    QuerySnapshot itemsQuery = await query.limit(limit).get();
    items.addAll(itemsQuery.docs.map(Item.fromDocumentSnapshot).toList());
    startAfterDoc = itemsQuery.docs.lastOrNull;

    if (itemsQuery.size != limit) {
      distance += BoundingBoxingQuery.kDistanceStep;
      startAfterDoc = null;
    }

    if (items.length == 20) {
      break;
    }
  }

  return BoundingBoxingQuery(items, distance < BoundingBoxingQuery.kMaxDistance,
      startAfterDoc, distance);
}

Future<QueryBatch<Item>> getItemsByTitle(String title,
    [DocumentSnapshot? startAfterDoc]) async {
  Query query = _firestore
      .collection('items')
      .where('title',
          isGreaterThanOrEqualTo: title,
          isLessThan: getNextAlphabeticalString(title))
      .limit(20);
  // TODO: add where by NOT current user (maybe order by createdAt?)

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get().then((QuerySnapshot itemsQuery) {
    List<Item> list = itemsQuery.docs.map(Item.fromDocumentSnapshot).toList();

    return QueryBatch(list, list.length == 20, itemsQuery.docs.lastOrNull);
  });
}

Future<Item> getItemById(String id) async {
  return getItemByRef(_firestore.collection('items').doc(id));
}

Future<Item> getItemByRef(DocumentReference itemRef) async {
  return itemRef.get().then(Item.fromDocumentSnapshot);
}

Future<List<Item>> _getItemsByQuery(
    Future<QuerySnapshot<Map<String, dynamic>>> query,
    bool onlyOthersItems) async {
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
  return _firestore
      .collection('items')
      .where('contactUserID', isEqualTo: userDetails.docRef.id)
      .orderBy('createdAt', descending: true)
      .snapshots();
}

Future<List<Item>> getItemsByContactUser(DocumentReference user) {
  return _getItemsByQuery(
      _firestore
          .collection('items')
          .where('contactUserID', isEqualTo: user.id)
          .get(),
      true);
}

//REQUESTS
Future<List<ItemRequest>> getUserRequestsStream() {
  return _firestore
      .collection('requests')
      .where('ownerID', isEqualTo: userDetails.docRef.id)
      .orderBy('requestTime', descending: true)
      .get()
      .then((QuerySnapshot query) =>
          query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Stream<List<ItemRequest>> getFutureRequestsStream(bool isUserOwner) {
  return _firestore
      .collection('requests')
      .where(isUserOwner ? 'ownerID' : 'applicantID',
          isEqualTo: userDetails.docRef.id)
      .where('time.start',
          isGreaterThanOrEqualTo: Timestamp.fromDate(getToday()))
      .orderBy('time.start')
      .snapshots()
      .map((QuerySnapshot query) =>
          query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Future<QueryBatch<ItemRequest>> getPastRequests(bool isUserOwner,
    [DocumentSnapshot? startAfterDoc]) {
  Query query = _firestore
      .collection('requests')
      .where(isUserOwner ? 'ownerID' : 'applicantID',
          isEqualTo: userDetails.docRef.id)
      .where('time.start', isLessThan: Timestamp.fromDate(getToday()))
      .orderBy('time.start', descending: true)
      .limit(20);

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get().then((QuerySnapshot itemsQuery) {
    List<ItemRequest> list =
        itemsQuery.docs.map(ItemRequest.fromDocumentSnapshot).toList();

    return QueryBatch(list, list.length == 20, itemsQuery.docs.lastOrNull);
  });
}

Future<List<ItemRequest>> getHistoryRequests() {
  return _firestore
      .collection('requests')
      .where('applicantID', isEqualTo: userDetails.docRef.id)
      .where('status', isEqualTo: RequestStatus.ownerApproved.index)
      .where('time.end', isLessThan: Timestamp.now())
      .orderBy('requestTime', descending: true)
      .get()
      .then((QuerySnapshot query) =>
          query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Stream<List<ItemRequest>> getFutureItemRequestsStream(
    DocumentReference itemRef) {
  return _firestore
      .collection('requests')
      .where('itemID', isEqualTo: itemRef.id)
      .where('time.end', isGreaterThan: Timestamp.now())
      .where('status', isNotEqualTo: RequestStatus.ownerRejected.index)
      .snapshots()
      .map((QuerySnapshot query) =>
          query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Future<List<ItemRequest>> getFutureItemRequests(String itemID) {
  return _firestore
      .collection('requests')
      .where('itemID', isEqualTo: itemID)
      .where('time.end', isGreaterThan: Timestamp.now())
      .where('status', isNotEqualTo: RequestStatus.ownerRejected.index)
      .get()
      .then((QuerySnapshot query) =>
          query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Stream<ItemRequest> getItemRequestStream(DocumentReference docRef) {
  return docRef.snapshots().map(ItemRequest.fromDocumentSnapshot);
}

void addRequest(Item item, DateTimeRange range) {
  _firestore.collection('requests').add({
    'ownerID': item.contactUserID,
    'applicantID': userDetails.docRef.id,
    'itemID': item.docRef.id,
    'status': RequestStatus.waiting.index,
    'time': {'start': range.start, 'end': range.end},
    'price': item.price,
    'latitude': item.latitude,
    'longitude': item.longitude,
    'requestTime': FieldValue.serverTimestamp(),
    'statusUpdateTime': FieldValue.serverTimestamp()
  });
}

void updateRequestStatus(DocumentReference docRef, RequestStatus status) {
  docRef.update({
    'status': status.index,
    'statusUpdateTime': FieldValue.serverTimestamp()
  });
}

void updateExtensionRequest(DocumentReference docRef, DateTime toDate) {
  docRef.update({
    'extensionRequest': {
      'toDate': toDate,
      'status': RequestStatus.waiting.index,
      'requestTime': FieldValue.serverTimestamp()
    }
  });
}

void removeExtensionRequest(DocumentReference docRef) {
  docRef.update({'extensionRequest': FieldValue.delete()});
}

void deleteRequest(DocumentReference docRef) {
  docRef.delete();
}

Future<List<ItemRequest>> getUserApprovedRequestsFrom(
    DateTime fromDate, bool isRentedFromMe) {
  String field = isRentedFromMe ? 'ownerID' : 'applicantID';
  return _firestore
      .collection('requests')
      .where(field, isEqualTo: userDetails.docRef.id)
      .where('status', isEqualTo: RequestStatus.ownerApproved.index)
      .where('time.start', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate))
      .get()
      .then((QuerySnapshot query) =>
          query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

Future<List<ItemRequest>> getCurrentRents(bool isRentedFromMe) {
  String field = isRentedFromMe ? 'ownerID' : 'applicantID';
  return _firestore
      .collection('requests')
      .where(field, isEqualTo: userDetails.docRef.id)
      .where('status', isEqualTo: RequestStatus.ownerApproved.index)
      .where('time.start', isLessThanOrEqualTo: Timestamp.now())
      .where('time.end', isGreaterThanOrEqualTo: Timestamp.now())
      .get()
      .then((QuerySnapshot query) =>
          query.docs.map(ItemRequest.fromDocumentSnapshot).toList());
}

//CHATS

Future<void> sendTextMessage(
    DocumentReference chatRef, bool isUserIndex0, String text) {
  WriteBatch batch = _firestore.batch();

  Map<String, dynamic> messageData = {
    'text': text,
    'sentBy0': isUserIndex0,
    'sentAt': FieldValue.serverTimestamp(),
    'type': MessageType.TEXT.index,
  };

  Map<String, dynamic> chatData = {
    'lastMessageTime': FieldValue.serverTimestamp(),
    'lastMessageContent': text,
    '${isUserIndex0 ? 'participantInfo0' : 'participantInfo1'}.typing': false,
    '${isUserIndex0 ? 'participantInfo1' : 'participantInfo0'}.unreadMessages':
        FieldValue.increment(1),
  };

  batch.set(chatRef.collection('messages').doc(), messageData);
  batch.update(chatRef, chatData);

  return batch.commit();
}

Future<void> sendImageMessage(
    DocumentReference chatRef, bool isUserIndex0, File image) async {
  WriteBatch batch = _firestore.batch();

  DocumentReference messageRef = chatRef.collection('messages').doc();

  await uploadFile(
      storageRef.child('messages').child('${messageRef.id}.jpg'), image);

  Map<String, dynamic> messageData = {
    'sentBy0': isUserIndex0,
    'sentAt': FieldValue.serverTimestamp(),
    'type': MessageType.IMAGE.index,
  };

  Map<String, dynamic> chatData = {
    'lastMessageTime': FieldValue.serverTimestamp(),
    'lastMessageContent': MessageType.IMAGE.index,
    '${isUserIndex0 ? 'participantInfo1' : 'participantInfo0'}.unreadMessages':
        FieldValue.increment(1),
  };

  batch.set(messageRef, messageData);
  batch.update(chatRef, chatData);

  batch.commit();
}

Future<void> sendRecordMessage(
    DocumentReference chatRef, bool isUserIndex0, File record) async {
  WriteBatch batch = _firestore.batch();

  DocumentReference messageRef = chatRef.collection('messages').doc();

  await uploadFile(storageRef.child('messages').child('${messageRef.id}.aac'),
      record, 'aac');

  Map<String, dynamic> messageData = {
    'sentBy0': isUserIndex0,
    'sentAt': FieldValue.serverTimestamp(),
    'type': MessageType.VOICE_RECORD.index,
  };

  Map<String, dynamic> chatData = {
    'lastMessageTime': FieldValue.serverTimestamp(),
    'lastMessageContent': MessageType.VOICE_RECORD.index,
    '${isUserIndex0 ? 'participantInfo1' : 'participantInfo0'}.unreadMessages':
        FieldValue.increment(1),
  };

  batch.set(messageRef, messageData);
  batch.update(chatRef, chatData);

  batch.commit();
}

class ChatOpenResult {
  final Chat chat;
  final bool isNew;

  ChatOpenResult({required this.chat, required this.isNew});
}

Future<ChatOpenResult> getOrCreateChatWithUser(String userID) async {
  Chat? existingChat = await _firestore
      .collection('chats')
      .where(Filter.or(
          Filter.and(
              Filter('participantInfo0.uid', isEqualTo: userDetails.docRef.id),
              Filter('participantInfo1.uid', isEqualTo: userID)),
          Filter.and(
              Filter('participantInfo0.uid', isEqualTo: userID),
              Filter('participantInfo1.uid',
                  isEqualTo: userDetails.docRef.id))))
      .limit(1)
      .get()
      .then((QuerySnapshot query) =>
          query.docs.map(Chat.fromDocumentSnapshot).firstOrNull);

  if (existingChat != null) {
    return ChatOpenResult(chat: existingChat, isNew: false);
  }

  DocumentReference chatRef = _firestore.collection('chats').doc();
  await chatRef.set({
    'lastMessageTime': FieldValue.serverTimestamp(),
    'lastMessageContent': '',
    'participantInfo0': {
      'uid': userDetails.docRef.id,
      'unreadMessages': 0,
      'lastMessageSeenTime': FieldValue.serverTimestamp(),
      'typing': false
    },
    'participantInfo1': {
      'uid': userID,
      'unreadMessages': 0,
      'lastMessageSeenTime': FieldValue.serverTimestamp(),
      'typing': false
    }
  });

  return ChatOpenResult(chat: await getChat(chatRef), isNew: true);
}

Future<void> deleteChatIfEmpty(DocumentReference chatRef) async {
  QuerySnapshot messages = await chatRef.collection('messages').limit(1).get();
  if (messages.docs.isEmpty) {
    await chatRef.delete();
  }
}

Future<DocumentReference> sendItemMessage(
    String userID, DocumentReference itemRef, String text) async {
  WriteBatch batch = _firestore.batch();

  DocumentReference chatRef;
  bool isUserIndex0;

  Chat? chat = await _firestore
      .collection('chats')
      .where(Filter.or(
          Filter.and(
              Filter('participantInfo0.uid', isEqualTo: userDetails.docRef.id),
              Filter('participantInfo1.uid', isEqualTo: userID)),
          Filter.and(
              Filter('participantInfo0.uid', isEqualTo: userID),
              Filter('participantInfo1.uid',
                  isEqualTo: userDetails.docRef.id))))
      .get()
      .then((QuerySnapshot query) =>
          query.docs.map(Chat.fromDocumentSnapshot).firstOrNull);

  if (chat != null) {
    chatRef = chat.docRef;
    isUserIndex0 = chat.participantInfo0.uid == userDetails.docRef.id;

    Map<String, dynamic> chatData = {
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageContent': text,
      '${isUserIndex0 ? 'participantInfo1' : 'participantInfo0'}.unreadMessages':
          FieldValue.increment(1),
    };

    batch.update(chatRef, chatData);
  } else {
    Map<String, dynamic> chatData = {
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageContent': text,
      'participantInfo0': {
        'uid': userDetails.docRef.id,
        'unreadMessages': 0,
        'lastMessageSeenTime': FieldValue.serverTimestamp(),
        'typing': false
      },
      'participantInfo1': {
        'uid': userID,
        'unreadMessages': 1,
        'lastMessageSeenTime': Timestamp.fromMillisecondsSinceEpoch(0),
        'typing': false
      }
    };

    chatRef = _firestore.collection('chats').doc();
    isUserIndex0 = true;

    batch.set(chatRef, chatData);
  }

  Map<String, dynamic> messageData = {
    'sentBy0': isUserIndex0,
    'text': text,
    'sentAt': FieldValue.serverTimestamp(),
    'type': MessageType.ITEM.index,
    'itemID': itemRef.id
  };

  batch.set(chatRef.collection('messages').doc(), messageData);

  await batch.commit();

  return chatRef;
}

Future<void> updateChatUserInfo(DocumentReference chatRef, bool isUserIndex0,
    DateTime lastMessageSeenTime) {
  String participantInfoIndex =
      isUserIndex0 ? 'participantInfo0' : 'participantInfo1';
  return chatRef.update({
    '$participantInfoIndex.lastMessageSeenTime':
        Timestamp.fromDate(lastMessageSeenTime),
    '$participantInfoIndex.unreadMessages': 0
  });
}

Future<void> updateChatUserTyping(
    DocumentReference chatRef, bool isUserIndex0, bool typing) {
  String participantInfoIndex =
      isUserIndex0 ? 'participantInfo0' : 'participantInfo1';
  return chatRef.update({'$participantInfoIndex.typing': typing});
}

Future<void> updateAllUserChatsTyping() {
  return _firestore
      .collection('chats')
      .where(Filter.or(
          Filter.and(
              Filter('participantInfo0.uid', isEqualTo: userDetails.docRef.id),
              Filter('participantInfo0.typing', isEqualTo: true)),
          Filter.and(
              Filter('participantInfo1.uid', isEqualTo: userDetails.docRef.id),
              Filter('participantInfo1.typing', isEqualTo: true))))
      .get()
      .then((QuerySnapshot query) {
    WriteBatch batch = _firestore.batch();
    query.docs.map(Chat.fromDocumentSnapshot).forEach((Chat chat) {
      bool isUserIndex0 = chat.participantInfo0.uid == userDetails.docRef.id;
      String participantInfoIndex =
          isUserIndex0 ? 'participantInfo0' : 'participantInfo1';
      batch.update(chat.docRef, {'$participantInfoIndex.typing': false});
    });
    return batch.commit();
  });
}

Stream<QuerySnapshot<Map<String, dynamic>>> getUserChatsSnapshotStream() {
  return _firestore
      .collection('chats')
      .where(Filter.or(
          Filter('participantInfo0.uid', isEqualTo: userDetails.docRef.id),
          Filter('participantInfo1.uid', isEqualTo: userDetails.docRef.id)))
      .orderBy('lastMessageTime', descending: true)
      .limit(20)
      .snapshots();
}

Future<QueryBatch<Chat>> getUserChats(DocumentSnapshot? startAfterDoc) {
  Query query = _firestore
      .collection('chats')
      .where(Filter.or(
          Filter('participantInfo0.uid', isEqualTo: userDetails.docRef.id),
          Filter('participantInfo1.uid', isEqualTo: userDetails.docRef.id)))
      .orderBy('lastMessageTime', descending: true)
      .limit(20);

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get().then((QuerySnapshot query) => QueryBatch(
      query.docs.map(Chat.fromDocumentSnapshot).toList(),
      query.size == 20,
      query.docs.lastOrNull));
}

Stream<int> getUserUnreadChatCountStream() {
  Query query = _firestore
      .collection('chats')
      .where(Filter.or(
          Filter.and(
              Filter('participantInfo0.uid', isEqualTo: userDetails.docRef.id),
              Filter('participantInfo0.unreadMessages', isGreaterThan: 0)),
          Filter.and(
              Filter('participantInfo1.uid', isEqualTo: userDetails.docRef.id),
              Filter('participantInfo1.unreadMessages', isGreaterThan: 0))))
      .limit(10);

  return query.snapshots().map((QuerySnapshot query) => query.size);
}

Stream<Chat> getChatStream(DocumentReference chatRef) {
  return chatRef.snapshots().map(Chat.fromDocumentSnapshot);
}

Future<Chat> getChatFromChatID(String chatID) async {
  return getChat(_firestore.collection('chats').doc(chatID));
}

Future<Chat> getChat(DocumentReference chatRef) async {
  return chatRef.get().then(Chat.fromDocumentSnapshot);
}

//MESSAGES

Stream<QueryBatch<Message>> getMessagesStream(DocumentReference chatRef) {
  Query query = chatRef
      .collection('messages')
      .orderBy('sentAt', descending: true)
      .limit(20);

  return query.snapshots().map((QuerySnapshot query) => QueryBatch(
      query.docChanges
          .where((DocumentChange change) =>
              change.type == DocumentChangeType.added)
          .map((DocumentChange change) =>
              Message.fromDocumentSnapshot(change.doc))
          .toList(),
      query.size == 20,
      query.docs.lastOrNull));
}

Future<QueryBatch<Message>> getMessages(
    DocumentReference chatRef, DocumentSnapshot? startAfterDoc) {
  Query query = chatRef
      .collection('messages')
      .orderBy('sentAt', descending: true)
      .limit(20);

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get().then((QuerySnapshot query) => QueryBatch(
      query.docs.map(Message.fromDocumentSnapshot).toList(),
      query.size == 20,
      query.docs.lastOrNull));
}

Reference getMessageFileRef(DocumentReference messageRef,
    [String fileExtension = 'jpg']) {
  return storageRef.child('messages').child('${messageRef.id}.$fileExtension');
}

//REVIEWS

void addItemReview(
    DocumentReference itemRef,
    int? overallRate,
    int? valueForPrice,
    int? compatibility,
    Condition? condition,
    String? text) {
  WriteBatch batch = _firestore.batch();
  batch.set(itemRef.collection('reviews').doc(), {
    'userID': userDetails.docRef.id,
    if (overallRate != null) 'overallRate': overallRate,
    if (valueForPrice != null) 'valueForPrice': valueForPrice,
    if (compatibility != null) 'compatibility': compatibility,
    if (text != '') 'text': text,
    if (condition != null) 'condition': condition.idx,
    'createdAt': FieldValue.serverTimestamp()
  });
  if (overallRate != null) {
    batch.update(itemRef, {
      'overallRateCount': FieldValue.increment(1),
      'overallRateSum': FieldValue.increment(overallRate)
    });
  }
  batch.commit();
}

Future<List<ItemReview>> getItemReviews(DocumentReference itemRef) async {
  return await itemRef
      .collection('reviews')
      .where('text', isNull: false)
      .orderBy('createdAt', descending: true)
      .get()
      .then((QuerySnapshot query) =>
          query.docs.map(ItemReview.fromDocumentSnapshot).toList());
}

void addUserReview(DocumentReference userRef, int? overallRate,
    int? availabilityLevel, int? punctualityLevel, String? text) {
  WriteBatch batch = _firestore.batch();
  batch.set(userRef.collection('reviews').doc(), {
    'userID': userDetails.docRef.id,
    if (overallRate != null) 'overallRate': overallRate,
    if (availabilityLevel != null) 'availabilityLevel': availabilityLevel,
    if (punctualityLevel != null) 'punctualityLevel': punctualityLevel,
    if (text != null && text != "") 'text': text,
    'createdAt': FieldValue.serverTimestamp()
  });
  if (overallRate != null) {
    batch.update(userRef, {
      'overallRateCount': FieldValue.increment(1),
      'overallRateSum': FieldValue.increment(overallRate)
    });
  }
  batch.commit();
}

Future<List<UserReview>> getUserReviews(DocumentReference userRef) async {
  return await userRef
      .collection('reviews')
      .where('text', isNull: false)
      .orderBy('createdAt', descending: true)
      .get()
      .then((QuerySnapshot query) =>
          query.docs.map(UserReview.fromDocumentSnapshot).toList());
}

Future<int> getTextItemReviewsCount(DocumentReference itemRef) async {
  return itemRef
      .collection('reviews')
      .where('text', isNull: false)
      .count()
      .get()
      .then((res) => res.count!);
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
  final user =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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

Future<void> createNewUser(
    String email, String password, String name, String phoneNumber) async {
  final newUser = await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
  userUid = newUser.user?.uid;
  DocumentReference userRef = _firestore.collection('users').doc(userUid);

  Map<String, dynamic> userData = {
    'fullName': name,
    'phoneNumber': int.parse(phoneNumber),
    'lastSeenTime': FieldValue.serverTimestamp(),
    'online': true
  };

  return userRef.set(userData);
}

void signOut() {
  _auth.signOut();
}

//USERS
Future<UserDetails> getUserByID(String id) async {
  return _firestore
      .collection('users')
      .doc(id)
      .get()
      .then(UserDetails.fromDocumentSnapshot);
}

Stream<UserDetails> getUserByIDStream(String id) {
  return _firestore
      .collection('users')
      .doc(id)
      .snapshots()
      .map(UserDetails.fromDocumentSnapshot);
}

Future<QueryBatch<Item>> getUserSeenItems([DocumentSnapshot? startAfterDoc]) {
  return _getUserItems('seen', 'seenTime', startAfterDoc);
}

Future<QueryBatch<Item>> getUserFavoriteItems(
    [DocumentSnapshot? startAfterDoc]) {
  return _getUserItems('favorites', 'updateTime', startAfterDoc);
}

Future<QueryBatch<Item>> getContactUserItems(DocumentReference user,
    [DocumentSnapshot? startAfterDoc]) async {
  Query query = _firestore
      .collection('items')
      .where('contactUserID', isEqualTo: user.id)
      .orderBy('createdAt', descending: true)
      .limit(20);
  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }
  return query.get().then((QuerySnapshot itemsSnapshot) {
    List<Item> items = itemsSnapshot.docs
        .map((QueryDocumentSnapshot snapshot) =>
            Item.fromDocumentSnapshot(snapshot))
        .toList();
    return QueryBatch(items, items.length == 20, itemsSnapshot.docs.lastOrNull);
  });
}

Future<QueryBatch<Item>> _getUserItems(String collectionName,
    String orderByFieldName, DocumentSnapshot? startAfterDoc) {
  Query query = userDetails.docRef
      .collection(collectionName)
      .orderBy(orderByFieldName, descending: true)
      .limit(20);

  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }

  return query.get().then((QuerySnapshot itemIdsQuery) {
    List<String> itemIds = itemIdsQuery.docs
        .map((QueryDocumentSnapshot snapshot) => snapshot.id)
        .toList();

    if (itemIds.isEmpty) {
      return QueryBatch<Item>([], false, itemIdsQuery.docs.lastOrNull);
    }

    return _firestore
        .collection('items')
        .where(FieldPath.documentId, whereIn: itemIds)
        .get()
        .then((QuerySnapshot itemsQuery) {
      List<Item> items =
          itemsQuery.docs.map(Item.fromDocumentSnapshot).toList();

      Map<String, Item> itemMap = {
        for (Item item in items) item.docRef.id: item
      };

      List<Item?> list = itemIds.map((String id) => itemMap[id]).toList();
      list.removeWhere((item) => item == null);

      return QueryBatch(list.cast<Item>(), itemIds.length == 20,
          itemIdsQuery.docs.lastOrNull);
    });
  });
}

Stream<bool> getUserFavoriteItem(DocumentReference itemRef) {
  return userDetails.docRef
      .collection('favorites')
      .doc(itemRef.id)
      .snapshots()
      .map((DocumentSnapshot snapshot) => snapshot.exists);
}

Reference getUserImageRef(DocumentReference userRef, String? photoID) {
  return storageRef.child('users').child('${userRef.id}_$photoID.jpg');
}

Future<int?> getUserItemCount(DocumentReference userRef) async {
  final countQuery = await _firestore
      .collection('items')
      .where('contactUserID', isEqualTo: userRef.id)
      .count()
      .get();

  return countQuery.count;
}

Future<int?> getUserRentCount(DocumentReference userRef) async {
  final countQuery = await _firestore
      .collection('requests')
      .where('ownerID', isEqualTo: userRef.id)
      .where('status', isEqualTo: RequestStatus.applicantApproved.index)
      .count()
      .get();

  return countQuery.count;
}

Future<void> updateUserItemSeen(DocumentReference itemRef) async {
  var batch = _firestore.batch();
  DocumentSnapshot snapshot =
      await userDetails.docRef.collection('seen').doc(itemRef.id).get();
  if (!snapshot.exists) {
    batch.update(itemRef, {'seenCount': FieldValue.increment(1)});
  }
  batch.set(userDetails.docRef.collection('seen').doc(itemRef.id),
      {'seenTime': FieldValue.serverTimestamp()});
  return batch.commit();
}

Future<void> updateUserPhotoID(DocumentReference userRef, String? photoID) {
  return userRef.update({'photoID': photoID ?? FieldValue.delete()});
}

Future<void> updateUserLastSeenTime([bool online = true]) {
  return userDetails.docRef
      .update({'lastSeenTime': FieldValue.serverTimestamp(), 'online': online});
}

Future<void> updateUserDetails(
    String name, int phoneNumber, bool showPhoneNumber) {
  Map<String, Object> data = {
    if (userDetails.name != name) 'fullName': name,
    if (userDetails.phoneNumber != phoneNumber) 'phoneNumber': phoneNumber,
    if (userDetails.showPhoneNumber != showPhoneNumber)
      'showPhoneNumber': showPhoneNumber,
  };
  return data.isNotEmpty ? userDetails.docRef.update(data) : Future.value();
}

Future<void> deleteOldUserItemSeen(DateTime dateTime) async {
  QuerySnapshot querySnapshot = await userDetails.docRef
      .collection('seen')
      .where('seenTime', isLessThan: dateTime)
      .limit(100)
      .get();

  for (final doc in querySnapshot.docs) {
    await doc.reference.delete();
  }
}

Future<void> toggleUserFavoriteItem(DocumentReference itemRef) async {
  var batch = _firestore.batch();
  DocumentSnapshot snapshot =
      await userDetails.docRef.collection('favorites').doc(itemRef.id).get();
  if (snapshot.exists) {
    batch.delete(snapshot.reference);
    batch.update(itemRef, {'favoriteCount': FieldValue.increment(-1)});
  } else {
    batch.set(snapshot.reference, {'updateTime': FieldValue.serverTimestamp()});
    batch.update(itemRef, {'favoriteCount': FieldValue.increment(1)});
  }
  return batch.commit();
}

Future<double?> getUserOverallRate(DocumentReference userRef) async {
  return userRef
      .get()
      .then((doc) => UserDetails.fromDocumentSnapshot(doc).getRate());
}

Future<double?> getUserAvailabilityLevel(DocumentReference userRef) async {
  return userRef
      .collection('reviews')
      .aggregate(average('availabilityLevel'))
      .get()
      .then((res) => res.getAverage('availabilityLevel'));
}

Future<double?> getUserPunctualityLevel(DocumentReference userRef) async {
  return userRef
      .collection('reviews')
      .aggregate(average('punctualityLevel'))
      .get()
      .then((res) => res.getAverage('punctualityLevel'));
}

//Messaging
Future<void> requestNotificationsPermission() async {
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

Future<void> setToken() async {
  if (Platform.isIOS) {
    String? apnsToken = await _messaging.getAPNSToken();
    int retries = 0;
    while (apnsToken == null && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      apnsToken = await _messaging.getAPNSToken();
      retries++;
    }
    if (apnsToken == null) {
      // APNs token is not ready yet on iOS. Skip now and rely on the next call.
      return;
    }
  }

  try {
    String? token = await _messaging.getToken();
    if (token != null && token != userDetails.token) {
      print('token: $token');
      userDetails.token = token;
      await userDetails.docRef.update({'token': token});
    }
  } on FirebaseException catch (e) {
    if (e.code != 'apns-token-not-set') {
      rethrow;
    }
  }
}

void onTokenRefreshed() {
  _messaging.onTokenRefresh.listen((newToken) {
    userDetails.token = newToken;
    userDetails.docRef.update({
      'token': newToken,
    });
  });
}

void messagingListenForeground() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null &&
        activeChat?.docRef.id != message.data['chatId']) {
      // showNotification(message.notification!.title, message.notification!.body, message);
    }
  });
}

void onMessageOpenedApp(BuildContext context) {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleNotificationTap(context, message.data);
  });
}

Future<void> messagingHandlerBackground(RemoteMessage message) async {
  if (message.notification != null) {
    print('----------------');
    handleNotificationOnBackGround(message.notification!);
    // showNotification(message.notification!.title, message.notification!.body, message);
  }
}
