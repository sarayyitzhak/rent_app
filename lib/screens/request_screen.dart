import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/request_status.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/request_widgets/extension_request_dialog.dart';

import '../dictionary.dart';
import '../models/item_request.dart';
import '../services/address_service.dart';
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

  Future<void> onCancelPressed(BuildContext context) async {
    var localization = Dictionary.getLocalization(context);
    if (_itemRequest.status == RequestStatus.waiting) {
      final bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(localization.deleteRequest),
            content: Text(localization.deleteConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(localization.no),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(localization.yes),
              ),
            ],
          );
        },
      );

      if (shouldDelete != true) {
        return;
      }

      final docRef = _itemRequest.docRef;
      if (!mounted) {
        return;
      }
      Navigator.pop(context);

      // Pop first so the user can see the card animate out on the requests list.
      unawaited(Future<void>.delayed(const Duration(milliseconds: 300), () {
        return deleteRequest(docRef);
      }));
    }
  }

  void fetchData() async {
    Item? item = await getItemById(_itemRequest.itemID);

    setState(() {
      _item = item;
    });

    _itemRequestSubscription =
        getItemRequestStream(_itemRequest.docRef).listen((itemRequest) {
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
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: localization.request,
        isBackButton: true,
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 90,
              child: Row(
                children: [
                  CachedImage(
                    width: 90,
                    height: 90,
                    imageRef: _item != null
                        ? getItemImageRef(_item!.docRef, _item!.mainImage)
                        : null,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localization.dates, style: kBlackHeaderTextStyle),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${dateToString(_itemRequest.time.start)}-${dateToString(_itemRequest.time.end)}',
                        style: kBlackHeaderTextStyle,
                        textAlign: TextAlign.end,
                      ),
                    )
                  ],
                ),
                _itemRequest.extensionRequest != null
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(localization.extensionUntil,
                                  style: TextStyle(fontSize: 14)),
                              Text(
                                  dateToString(
                                      _itemRequest.extensionRequest!.toDate),
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(localization.requestStatus,
                                  style: TextStyle(fontSize: 14)),
                              Text(
                                  _itemRequest.extensionRequest!.status
                                      .getTitle(localization),
                                  style: const TextStyle(fontSize: 14))
                            ],
                          ),
                          ElevatedButton(
                            onPressed: onCancelExtensionPressed,
                            child: Text(localization.cancelRequest),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localization.requestStatus, style: kBlackHeaderTextStyle),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_itemRequest.status.getTitle(localization),
                      style: kBlackHeaderTextStyle, textAlign: TextAlign.end),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.finalPrice,
                  style: kBlackHeaderTextStyle,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    getFormattedFinalPrice(),
                    style: kBlackHeaderTextStyle,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.pickupLocation,
                  style: kBlackHeaderTextStyle,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FutureBuilder(
                    future: AddressService().getAddress(_itemRequest.geoPoint),
                    builder: (context, snapshot) => Text(
                      snapshot.data ?? '',
                      style: kBlackHeaderTextStyle,
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Column(
                children: [
                  CustomButton(
                      title: localization.askForExtension,
                      onPress: onExtensionPressed),
                  CustomButton(
                      title: _itemRequest.status == RequestStatus.waiting
                          ? localization.deleteRequest
                          : localization.cancelRequest,
                      onPress: () => onCancelPressed(context))
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
