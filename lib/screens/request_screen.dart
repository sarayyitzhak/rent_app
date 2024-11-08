import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/request_status.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/request_widgets/extension_request_dialog.dart';

import '../models/item_request.dart';
import '../utils.dart';
import '../widgets/cached_image.dart';

class RequestScreen extends StatefulWidget {
  static String id = 'request_screen';

  final RequestScreenArguments args;

  const RequestScreen(this.args, {super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  late ItemRequest _itemRequest;
  Item? _item;

  StreamSubscription? _itemRequestSubscription;

  String getFormattedFinalPrice() {
    ItemRequest itemRequest = _itemRequest;
    int finalPrice = (itemRequest.time.duration.inDays + 1) * itemRequest.price;
    return getFormattedPrice(finalPrice);
  }

  void onExtensionPressed() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ExtensionRequestDialog(itemRequest: _itemRequest);
        });
  }

  void onCancelExtensionPressed() {
    removeExtensionRequest(_itemRequest.docRef);
  }

  void onCancelPressed() {
    if (_itemRequest.status == RequestStatus.WAITING) {
      deleteRequest(_itemRequest.docRef);
      Navigator.pop(context);
    }
  }

  void fetchData() async {
    Item? item = await getItemById(_itemRequest.itemID);

    setState(() {
      _item = item;
    });

    _itemRequestSubscription = getItemRequestStream(_itemRequest.docRef).listen((itemRequest) {
      setState(() {
        _itemRequest = itemRequest;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _itemRequest = widget.args.itemRequest;
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();

    _itemRequestSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'בקשה',
        isBackButton: true,
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 90,
              child: Row(
                children: [
                  CachedImage(
                    width: 90,
                    height: 90,
                    imageRef: _item != null ? getItemMainImageRef(_item!.docRef, _item!.mainImage) : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _item?.title ?? '',
                        style: kHeadersTextStyle,
                      ),
                      Text(
                        getFormattedPrice(_itemRequest.price),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('תאריכים:', style: kBlackHeaderTextStyle),
                    Text(
                        '${dateToString(_itemRequest.time.start)}-${dateToString(_itemRequest.time.end)}',
                        style: kBlackHeaderTextStyle)
                  ],
                ),
                _itemRequest.extensionRequest != null ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('הארכה עד:', style: TextStyle(fontSize: 14)),
                        Text(dateToString(_itemRequest.extensionRequest!.toDate), style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('מצב בקשה:', style: TextStyle(fontSize: 14)),
                        Text(_itemRequest.extensionRequest!.status.getTitle(localization), style: TextStyle(fontSize: 14))
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onCancelExtensionPressed,
                      child: Text("בטל בקשה"),
                    ),
                  ],
                ) : Container(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('מצב בקשה:', style: kBlackHeaderTextStyle),
                Text(_itemRequest.status.getTitle(localization), style: kBlackHeaderTextStyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'מחיר סופי:',
                  style: kBlackHeaderTextStyle,
                ),
                Text(
                  getFormattedFinalPrice(),
                  style: kBlackHeaderTextStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'מקום איסוף:',
                  style: kBlackHeaderTextStyle,
                ),
                Text(
                  _itemRequest.pickUpLocation.addressDataToString(),
                  style: kBlackHeaderTextStyle,
                ),
              ],
            ),
            Center(
              child: Column(
                children: [
                  CustomButton(title: 'בקש הארכה', onPress: onExtensionPressed),
                  CustomButton(title: _itemRequest.status == RequestStatus.WAITING ? 'מחק בקשה' : 'בטל בקשה', onPress: onCancelPressed)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestScreenArguments {
  ItemRequest itemRequest;

  RequestScreenArguments({required this.itemRequest});
}
