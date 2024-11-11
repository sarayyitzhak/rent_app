import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_app/utils.dart';

import '../../dictionary.dart';

class DateBubble extends StatelessWidget {
  final DateTime dateTime;

  const DateBubble({super.key, required this.dateTime});

  String getDateAsText(BuildContext context) {
    final now = DateTime.now();
    AppLocalizations localization = Dictionary.getLocalization(context);
    if (now.year == dateTime.year && now.month == dateTime.month) {
      int daysDifference = getDaysDifference(dateTime, now);
      if (daysDifference == 0) {
        return localization.today;
      }
      if (daysDifference == 1) {
        return localization.yesterday;
      }
      if (daysDifference < 7) {
        return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(dateTime);
      }
    }
    return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[200],
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                getDateAsText(context)
            ),
          ],
        )
      ),
    );
  }
}
