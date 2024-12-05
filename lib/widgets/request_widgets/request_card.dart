import 'package:flutter/material.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/screens/item_review_screen.dart';
import 'package:rent_app/screens/request_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import '../../constants.dart';
import '../../dictionary.dart';
import '../../models/request_status.dart';
import '../../utils.dart';
import '../cached_image.dart';

class RequestCard extends StatefulWidget {
  final ItemRequest request;

  const RequestCard({super.key, required this.request});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  Item? _item;
  late RequestStatus _status;

  Widget getStatusWidget(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    if (widget.request.applicantID == userDetails.docRef.id) {
      if (_status == RequestStatus.ownerApproved) {
        return Row(
          children: [
            createStatusButton(localization.accept, RequestStatus.applicantApproved, Colors.green),
            const SizedBox(width: 5),
            createStatusButton(localization.reject, RequestStatus.applicantRejected, Colors.red)
          ],
        );
      } else {
        return Text(_status.getTitle(localization));
      }
    } else if (widget.request.ownerID == userDetails.docRef.id) {
      if (_status == RequestStatus.waiting) {
        return Row(
          children: [
            createStatusButton(localization.accept, RequestStatus.ownerApproved, Colors.green),
            const SizedBox(width: 5),
            createStatusButton(localization.reject, RequestStatus.ownerRejected, Colors.red)
          ],
        );
      } else {
        return Text(_status.getTitle(localization));
      }
    } else {
      return Text(localization.error);
    }
  }

  ElevatedButton createStatusButton(String title, RequestStatus status, Color color) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _status = status;
          updateRequestStatus(widget.request.docRef, status);
        });
      },
      child: Text(title),
      style: ElevatedButton.styleFrom(
          foregroundColor: kWhiteColor, backgroundColor: color, elevation: 3, textStyle: kWhiteTextStyle),
    );
  }

  void fetchData() async {
    Item? item = await getItemById(widget.request.itemID);

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
          ? () async => Navigator.pushNamed(context, ItemReviewScreen.id, arguments: ItemReviewScreenArguments(_item!))
          : () => Navigator.pushNamed(context, RequestScreen.id,
              arguments: RequestScreenArguments(itemRequest: widget.request)),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CachedImage(
                    width: 100,
                    height: 100,
                    imageRef: _item != null ? getItemImageRef(_item!.docRef, _item!.mainImage) : null,
                    borderRadius: const BorderRadiusDirectional.only(
                        topStart: Radius.circular(20), bottomStart: Radius.circular(20)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _item?.title ?? '',
                        style: kBlackHeaderTextStyle,
                      ),
                      Text(
                        '${dateToString(widget.request.time.start)}-${dateToString(widget.request.time.end)}',
                        style: kSmallBlackTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: getStatusWidget(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
