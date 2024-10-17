import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/main.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/request.dart';
import 'package:rent_app/screens/request_submitted_screen.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:rent_app/widgets/custom_button.dart';

import '../models/request_status.dart';
import '../services/cloud_services.dart';

class RentalScreen extends StatefulWidget {
  static String id = 'rental_screen';
  RentalScreen({super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  DateTimeRange currentDate = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  int totalTime = 0;
  int totalPrice = 0;

  String dateToString(DateTime? date) {
    return '${date!.day.toString()}/${date!.month.toString()}/${date!.year.toString()}';
  }

  String timeToString(DateTime? date) {
    return '${date?.hour.toString()}:${date?.minute.toString()}';
  }

  void onPickDatesPressed() async {
    final date = await showRangePickerDialog(
        context: context,
        minDate: DateTime(2021, 1, 1),
        maxDate: DateTime(2030, 12, 31),
        selectedRange: currentDate);
    setState(() {
      currentDate = date!;
      getTotalTime();
    });
  }

  void onPickHourPressed(bool isStart) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: isStart ? TimeOfDay(hour: currentDate.start.hour, minute: currentDate.start.minute) : TimeOfDay(hour: currentDate.end.hour, minute: currentDate.end.minute),
      // initialEntryMode: entryMode,
      // orientation: orientation,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context),
          child: Directionality(
            textDirection: TextDirection.rtl,//TODO: change based on the language
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            ),
          ),
        );
      },
    );
    setState(() {
      if(isStart){
        currentDate = DateTimeRange(start: DateTime(currentDate.start.year, currentDate.start.month, currentDate.start.day, time!.hour, time.minute,), end: DateTime(currentDate.end.year, currentDate.end.month, currentDate.end.day, currentDate.end.hour == 0 ? time!.hour + 1 : currentDate.end.hour, currentDate.end.hour == 0 ? time!.hour + 1 : currentDate.end.hour == 0 ? time.minute : currentDate.end.minute));
      } else {
        currentDate = DateTimeRange(start: currentDate.start, end: DateTime(currentDate.end.year, currentDate.end.month, currentDate.end.day, time!.hour, time.minute));
      }
      getTotalTime();
    });
  }

  String getTotalTime() {
    totalTime = currentDate.duration.inDays;
    if(totalTime == 0){
      totalTime = currentDate.duration.inHours;
      return '$totalTime שעות';
    } else {
      return '$totalTime ימים';
    }
  }

  int getTotalPrice(Item item) {
    return item.price;
  }

  void onSendRequestPressed(Item item){
    //TODO: send notification
    ItemRequest request = ItemRequest(ownerID: item.contactUser.id, applicantID: userDetails.userReference.id, itemID: item.itemReference.id, status: RequestStatus.WAITING, time: currentDate, finalPrice: totalPrice, pickUpLocation: item.location, requestTime: Timestamp.now());
    addRequest(request);
    Navigator.pushNamed(context, RequestSubmittedScreen.id);
  }
  
  @override
  Widget build(BuildContext context) {
    final arg =
        ModalRoute.of(context)!.settings.arguments as RentalScreenArgument;
    Item item = arg.item;
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'בקשה לשכירת מוצר',
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
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(item.imageRef),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        item.title,
                        style: kHeadersTextStyle,
                      ),
                      Text(
                        '${item.price}₪',
                      ),
                    ],
                  )
                ],
              ),
            ),
            // SizedBox(
            //   height: 50,
            // ),
            Text(
              'מתי תרצה להשתמש במוצר?',
              style: kBlackHeaderTextStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('מיום:'),
                TextButton(
                    onPressed: onPickDatesPressed, child: Text(dateToString(currentDate.start))),
                Text('עד יום:'),
                TextButton(onPressed: onPickDatesPressed, child: Text(dateToString(currentDate.end))),
              ],
            ),
            currentDate.start.day == currentDate.end.day && currentDate.start.month == currentDate.end.month
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('משעה:'),
                      TextButton(
                          onPressed: () => onPickHourPressed(true), child: Text(timeToString(currentDate.start))),
                      Text('עד שעה:'),
                      TextButton(
                          onPressed: () => onPickHourPressed(false), child: Text(timeToString(currentDate.end))),
                    ],
                  )
                : Container(),
            totalTime != 0
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('בסה"כ:', style: kBlackHeaderTextStyle,),
                    Text(getTotalTime(), style: kBlackHeaderTextStyle,)
                  ],
                )
                : Container(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('מחיר סופי:', style: kBlackHeaderTextStyle,),
                Text(getTotalPrice(item).toString(), style: kBlackHeaderTextStyle,),
              ],
            ),

            // SizedBox(height: 40,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('מקום איסוף:', style: kBlackHeaderTextStyle,),
                Text(item.location.addressDataToString(), style: kBlackHeaderTextStyle,),
              ],
            ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Text('פרטי מוכר:', style: kBlackHeaderTextStyle,),
            //     Text(item., style: kBlackHeaderTextStyle,),
            //   ],
            // ),


            Align(
                alignment: Alignment.bottomCenter,
                child: CustomButton(title: 'הגש בקשה', onPress: () => onSendRequestPressed(item))),
          ],
        ),
      ),
    );
  }
}

class RentalScreenArgument {
  Item item;
  RentalScreenArgument({required this.item});
}

class CustomDatePickerRange extends StatefulWidget {
  const CustomDatePickerRange({super.key});

  @override
  State<CustomDatePickerRange> createState() => _CustomDatePickerRangeState();
}

class _CustomDatePickerRangeState extends State<CustomDatePickerRange> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
