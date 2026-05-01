import 'package:flutter/material.dart';
import 'package:rent_app/models/item_request.dart';
import 'active_rent_card.dart';

class ScrollableActiveRentList extends StatelessWidget {
  final bool isRentedFromMe;
  final String title;
  final List<ItemRequest> rentals;
  const ScrollableActiveRentList(
      {super.key,
      required this.isRentedFromMe,
      required this.title,
      required this.rentals});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(title),
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    rentals.map((e) => ActiveRentCard(request: e)).toList(),
              ),
            ),
          ],
        ));
  }
}
