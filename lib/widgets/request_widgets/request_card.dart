import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/screens/item_review_screen.dart';
import 'package:rent_app/screens/request_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import '../../constants.dart';
import '../../models/request_status.dart';
import '../../utils.dart';

class RequestCard extends StatefulWidget {
  final ItemRequest request;

  const RequestCard({super.key, required this.request});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {

  Item? _item;
  RequestStatus? _status;

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
          foregroundColor: kWhiteColor,
          backgroundColor: color,
          elevation: 3,
          textStyle: kWhiteTextStyle),
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

    _status = widget.request.status;
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: widget.request.status == RequestStatus.APPROVED ? () async => Navigator.pushNamed(context, ItemReviewScreen.id,
          arguments: ItemReviewScreenArguments(await getItemById(widget.request.itemID) as Item))
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
                  CachedNetworkImage(
                    width: 100,
                    height: 100,
                    imageUrl: _item?.imageRef ?? '',
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadiusDirectional.only(
                            topStart: Radius.circular(20),
                            bottomStart: Radius.circular(20)
                        ),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
                child: widget.request.applicantID == userDetails.docRef.id ||
                        _status != RequestStatus.WAITING
                    ? Text(_status!.getTitle(localization))
                    : Row(
                        children: [
                          createStatusButton(localization.accept,
                              RequestStatus.APPROVED, Colors.green),
                          const SizedBox(width: 5),
                          createStatusButton(localization.reject,
                              RequestStatus.REJECTED, Colors.red)
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
