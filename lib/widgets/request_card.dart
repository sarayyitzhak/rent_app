import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/models/request.dart';
import 'package:rent_app/services/cloud_services.dart';
import '../constants.dart';
import '../models/requestStatus.dart';
import '../utils.dart';

class RequestCard extends StatefulWidget {
  AppLocalizations localization;
  bool isMyRequest;
  ItemRequest request;
  RequestCard({super.key, required this.localization, required this.isMyRequest, required this.request});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {

  @override
  Widget build(BuildContext context) {
    return widget.request.item != null
        ? Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 70,
                width: 70,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.request.item!.imageRef,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    widget.request.item!.title,
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
              child: widget.isMyRequest || widget.request.status != RequestStatus.WAITING
                  ? Text(widget.request.status.getTitle(widget.localization))
                  : Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.request.status = RequestStatus.REJECTED;
                        updateRequestStatus(widget.request);
                      });
                    },
                    child: Text(widget.localization.reject),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: kWhiteColor,
                        backgroundColor: Colors.red,
                        elevation: 3,
                        textStyle: kWhiteTextStyle),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.request.status = RequestStatus.APPROVED;
                        updateRequestStatus(widget.request);
                      });
                    },
                    child: Text(widget.localization.accept),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: kWhiteColor,
                        backgroundColor: Colors.green,
                        elevation: 3,
                        textStyle: kWhiteTextStyle),
                  )
                ],
              ),
          ),
        ],
      ),
    )
        : Container();
  }
}
