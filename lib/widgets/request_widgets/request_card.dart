import 'package:flutter/material.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/screens/item_review_screen.dart';
import 'package:rent_app/screens/request_screen.dart';
import 'package:rent_app/services/address_service.dart';
import 'package:rent_app/services/cloud_services.dart';
import '../../constants.dart';
import '../../dictionary.dart';
import '../../models/request_status.dart';
import '../../utils.dart';
import '../cached_image.dart';

class RequestCard extends StatefulWidget {
  final ItemRequest request;
  final Item? item;

  const RequestCard({super.key, required this.request, this.item});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  Item? _item;
  late RequestStatus _status;

  Color? getBackgroundColor() {
    if (_status == RequestStatus.waiting) {
      return Colors.orange[50];
    } else if (_status == RequestStatus.applicantApproved || _status == RequestStatus.ownerApproved) {
      return Colors.green[50];
    } else if (_status == RequestStatus.applicantRejected || _status == RequestStatus.ownerRejected) {
      return Colors.red[50];
    } else {
      return Colors.grey[100];
    }
  }

  Color? getColor() {
    if (_status == RequestStatus.waiting) {
      return Colors.orange[800];
    } else if (_status == RequestStatus.applicantApproved || _status == RequestStatus.ownerApproved) {
      return Colors.green[800];
    } else if (_status == RequestStatus.applicantRejected || _status == RequestStatus.ownerRejected) {
      return Colors.red[800];
    } else {
      return Colors.grey[800];
    }
  }

  Widget getStatusWidget(BuildContext context) {
    var localization = Dictionary.getLocalization(context);

    if (widget.request.applicantID == userDetails.docRef.id) {
      if (_status == RequestStatus.ownerApproved) {
        return Row(
          children: [
            createStatusButton(localization.accept,
                RequestStatus.applicantApproved, Colors.green),
            const SizedBox(width: 5),
            createStatusButton(localization.reject,
                RequestStatus.applicantRejected, Colors.red)
          ],
        );
      }
    } else if (widget.request.ownerID == userDetails.docRef.id) {
      if (_status == RequestStatus.waiting) {
        return Row(
          children: [
            createStatusButton(
                localization.accept, RequestStatus.ownerApproved, Colors.green),
            const SizedBox(width: 5),
            createStatusButton(
                localization.reject, RequestStatus.ownerRejected, Colors.red)
          ],
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.circular(8),
        color: getBackgroundColor(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          _status.getTitle(localization),
          style: TextStyle(color: getColor()),
        ),
      ),
    );
  }

  ElevatedButton createStatusButton(
      String title, RequestStatus status, Color color) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _status = status;
          updateRequestStatus(widget.request.docRef, status);
        });
      },
      style: ElevatedButton.styleFrom(
          foregroundColor: kWhiteColor,
          backgroundColor: color,
          elevation: 3,
          textStyle: kWhiteTextStyle),
      child: Text(title),
    );
  }

  String getFormattedFinalPrice() {
    int finalPrice = (widget.request.time.duration.inDays + 1) * widget.request.price;
    return getFormattedPrice(finalPrice);
  }

  void fetchData() async {
    Item? item = widget.item ?? await getItemById(widget.request.itemID);

    setState(() {
      _item = item;
    });
  }

  @override
  void initState() {
    super.initState();

    _status = getRequestStatus(widget.request);
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return GestureDetector(
      onTap: widget.request.status == RequestStatus.ownerApproved
          ? () async => Navigator.pushNamed(context, ItemReviewScreen.id,
              arguments: ItemReviewScreenArguments(_item!))
          : () => Navigator.pushNamed(context, RequestScreen.id,
              arguments: RequestScreenArguments(itemRequest: widget.request)),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          height: 100,
          child: Row(
            children: [
              Row(
                children: [
                  CachedImage(
                    width: 100,
                    height: 100,
                    imageRef: _item != null
                        ? getItemImageRef(_item!.docRef, _item!.mainImage)
                        : null,
                    borderRadius: const BorderRadiusDirectional.only(
                        topStart: Radius.circular(20),
                        bottomStart: Radius.circular(20)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _item?.title ?? '',
                        style: kBlackHeaderTextStyle,
                      ),
                    ),
                    PositionedDirectional(
                      start: 0,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _item?.title ?? '',
                            style: kBlackHeaderTextStyle,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                color: getColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${dateToString(widget.request.time.start)} - ${dateToString(widget.request.time.end)}',
                                textDirection: TextDirection.ltr,
                                style: TextStyle(color: getColor(), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              FutureBuilder(
                                future: AddressService().getAddress(widget.request.geoPoint),
                                builder: (context, snapshot) => Text(
                                  snapshot.data ?? '',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 8,
                      end: 16,
                      child: Text(
                        getFormattedFinalPrice(),
                        style: kHeadersTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
