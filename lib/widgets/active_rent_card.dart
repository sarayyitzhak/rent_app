import 'package:flutter/material.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/screens/item_review_screen.dart';
import 'package:rent_app/screens/request_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import '../../constants.dart';
import '../../models/request_status.dart';
import '../../utils.dart';
import 'cached_image.dart';

class ActiveRentCard extends StatefulWidget {
  final ItemRequest request;

  const ActiveRentCard({super.key, required this.request});

  @override
  State<ActiveRentCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<ActiveRentCard> {

  Item? _item;

  void fetchData() async {
    Item? item = await getItemById(widget.request.itemID);
    setState(() {
      _item = item;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.request.status == RequestStatus.APPROVED ? () async => Navigator.pushNamed(context, ItemReviewScreen.id,
          arguments: ItemReviewScreenArguments(await getItemById(widget.request.itemID) as Item))
          : () => Navigator.pushNamed(context, RequestScreen.id,
          arguments: RequestScreenArguments(itemRequest: widget.request)),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CachedImage(
                    width: 110,
                    height: 150,
                    imageRef: _item != null ? getItemImageRef(_item!.docRef, _item!.mainImage) : null,
                    borderRadius: const BorderRadiusDirectional.only(
                        topStart: Radius.circular(20),
                        bottomStart: Radius.circular(20)
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
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
                        SizedBox(height: 8, width: 100, child: LinearProgressIndicator(value: widget.request.getActiveRentProgressTime()!, color: kDarkYellow, backgroundColor: kPastelYellowOpacity, borderRadius: BorderRadius.circular(6),)),
                        if(DateTime.now().isAfter(widget.request.time.end)) Text('זהו היום האחרון להשכרה'), // lastDay
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
