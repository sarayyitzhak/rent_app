import 'dart:async';
import 'dart:developer';

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
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../models/request_status.dart';
import '../services/cloud_services.dart';
import '../utils.dart';

class RentalScreen extends StatefulWidget {
  static String id = 'rental_screen';
  const RentalScreen({super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  late Item _item;
  final DateRangePickerController _controller = DateRangePickerController();
  int totalPrice = 0;

  List<DateTime> _blackoutDates = [];
  List<DateTime> _waitingDates = [];

  StreamSubscription? _itemRequestsSubscription;

  void onSendRequestPressed(){
    //TODO: send notification
    DateTimeRange? dateTimeRange = _getDateTimeRange();
    if (dateTimeRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("נבחר טווח תאריכים לא חוקי")),
      );
      return;
    }

    ItemRequest request = ItemRequest(ownerID: _item.contactUser.id, applicantID: userDetails.userReference.id, itemID: _item.itemReference.id, status: RequestStatus.WAITING, time: dateTimeRange, finalPrice: totalPrice, pickUpLocation: _item.location, requestTime: Timestamp.now());
    addRequest(request);
    Navigator.pushNamed(context, RequestSubmittedScreen.id);
  }

  DateTimeRange? _getDateTimeRange() {
    if (_getSelectedStartDate() == null) {
      return null;
    }
    return DateTimeRange(start: _getSelectedStartDate()!, end: _getSelectedEndDate()!);
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (_getSelectedStartDate() == null) {
      return;
    }

    if (_isSelectedRangeContainsBlackoutDates()) {
      setState(() {
        _controller.selectedRange = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("טווח התאריכים מכיל תאריך תפוס. אנא בחר טווח אחר")),
      );
    } else {
      setState(() {
        totalPrice = _item.price * (_getSelectedEndDate()!.difference(_getSelectedStartDate()!).inDays + 1);
      });
    }
  }

  DateTime? _getSelectedStartDate() {
    return _controller.selectedRange?.startDate;
  }

  DateTime? _getSelectedEndDate() {
    return _controller.selectedRange?.endDate ?? _getSelectedStartDate();
  }

  bool _isSelectedRangeContainsBlackoutDates() {
    if (_getSelectedStartDate() == null) {
      return false;
    }

    return _blackoutDates.any((date) => date.isAfter(_getSelectedStartDate()!) && date.isBefore(_getSelectedEndDate()!));
  }

  void _updateDates() async {
    _itemRequestsSubscription = getFutureItemRequestsStream(_item.itemReference).listen((List<ItemRequest> itemRequests) {
      List<DateTime> blackoutDates = [];
      List<DateTime> waitingDates = [];

      for (ItemRequest itemRequest in itemRequests) {
        DateTime currentDate = itemRequest.time.start;

        while (!itemRequest.time.end.isBefore(currentDate)) {
          if (itemRequest.status == RequestStatus.APPROVED) {
            blackoutDates.add(currentDate);
          }
          if (itemRequest.status == RequestStatus.WAITING) {
            waitingDates.add(currentDate);
          }
          currentDate = currentDate.add(Duration(days: 1));
        }
      }

      setState(() {
        _blackoutDates = blackoutDates;
        _waitingDates = waitingDates;
      });

      if (_isSelectedRangeContainsBlackoutDates()) {
        setState(() {
          _controller.selectedRange = null;
        });
      }
    });
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)!.settings.arguments as RentalScreenArgument;
      _item = arg.item;

      _updateDates();
    });
  }

  @override
  void dispose() {
    super.dispose();

    _itemRequestsSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    final arg = ModalRoute.of(context)!.settings.arguments as RentalScreenArgument;
    Item item = arg.item;
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
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        item.title,
                        style: kHeadersTextStyle,
                      ),
                      Text(
                        getFormattedPrice(item.price),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Text(
              'מתי תרצה להשתמש במוצר?',
              style: kBlackHeaderTextStyle,
            ),
            SfDateRangePicker(
              controller: _controller,
              view: DateRangePickerView.month,
              selectionMode: DateRangePickerSelectionMode.range,
              enablePastDates: false,
              todayHighlightColor: Colors.blue,
              backgroundColor: Colors.transparent,
              startRangeSelectionColor: Colors.blue,
              endRangeSelectionColor: Colors.blue,
              rangeSelectionColor: Colors.blue.withOpacity(0.2),
              headerStyle: DateRangePickerHeaderStyle(
                backgroundColor: Colors.transparent,
              ),
              onSelectionChanged: _onSelectionChanged,
              monthCellStyle: DateRangePickerMonthCellStyle(
                todayTextStyle: TextStyle(
                  color: Colors.blue,
                ),
                cellDecoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                disabledDatesDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                disabledDatesTextStyle: TextStyle(
                    color: Colors.grey
                ),
                blackoutDatesDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                blackoutDateTextStyle: TextStyle(
                  color: Colors.grey
                ),
                specialDatesDecoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
              monthViewSettings: DateRangePickerMonthViewSettings(
                enableSwipeSelection: false,
                blackoutDates: _blackoutDates,
                specialDates: _waitingDates,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('מחיר סופי:', style: kBlackHeaderTextStyle,),
                Text(getFormattedPrice(totalPrice), style: kBlackHeaderTextStyle,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('מקום איסוף:', style: kBlackHeaderTextStyle,),
                Text(item.location.addressDataToString(), style: kBlackHeaderTextStyle,),
              ],
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: CustomButton(title: 'הגש בקשה', onPress: () => onSendRequestPressed())
            ),
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
