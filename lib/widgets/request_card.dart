import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/models/request.dart';
import 'package:rent_app/services/cloud_services.dart';
import '../constants.dart';
import '../models/request_status.dart';
import '../utils.dart';

class RequestCard extends StatefulWidget {
  final AppLocalizations localization;
  final bool isMyRequest;
  final ItemRequest request;
  const RequestCard({super.key, required this.localization, required this.isMyRequest, required this.request});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {

  ElevatedButton createStatusButton(String title, RequestStatus status, Color color){
    return ElevatedButton(
      onPressed: () {
        setState(() {
          widget.request.status = status;
          updateRequestStatus(widget.request);
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
                  createStatusButton(widget.localization.accept, RequestStatus.APPROVED, Colors.green),
                  const SizedBox(width: 5),
                  createStatusButton(widget.localization.reject, RequestStatus.REJECTED, Colors.red)
                ],
              ),
          ),
        ],
      ),
    )
        : Container();
  }
}
