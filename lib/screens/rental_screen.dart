import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/screens/request_submitted_screen.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../models/request_status.dart';
import '../services/cloud_services.dart';
import '../utils.dart';
import '../widgets/cached_image.dart';

class RentalScreen extends StatefulWidget {
  static String id = 'rental_screen';

  final RentalScreenArguments args;
  const RentalScreen(this.args, {super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  final DateRangePickerController _controller = DateRangePickerController();
  int totalPrice = 0;

  List<DateTime> _blackoutDates = [];
  List<DateTime> _waitingDates = [];

  StreamSubscription? _itemRequestsSubscription;

  void onSendRequestPressed(){
    DateTimeRange? dateTimeRange = _getDateTimeRange();
    if (dateTimeRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("נבחר טווח תאריכים לא חוקי")),
      );
      return;
    }

    addRequest(widget.args.item, dateTimeRange);
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
        totalPrice = widget.args.item.price * (_getSelectedEndDate()!.difference(_getSelectedStartDate()!).inDays + 1);
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
    _itemRequestsSubscription = getFutureItemRequestsStream(widget.args.item.docRef).listen((List<ItemRequest> itemRequests) {
      List<DateTime> blackoutDates = [];
      List<DateTime> waitingDates = [];

      for (ItemRequest itemRequest in itemRequests) {
        if (itemRequest.status == RequestStatus.WAITING) {
          waitingDates.addAll(getDateList(itemRequest.time));
        } else if (itemRequest.status == RequestStatus.APPROVED) {
          blackoutDates.addAll(getDateList(itemRequest.time));

          if (itemRequest.extensionRequest != null && itemRequest.extensionRequest!.status == RequestStatus.WAITING) {
            var start = itemRequest.time.end.add(const Duration(days: 1));
            var end = itemRequest.extensionRequest!.toDate;
            waitingDates.addAll(getDateList(DateTimeRange(start: start, end: end)));
          }
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

    _updateDates();
  }

  @override
  void dispose() {
    super.dispose();

    _itemRequestsSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
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
                  CachedImage(
                    height: 90,
                    width: 90,
                    imageRef: getItemImageRef(widget.args.item.docRef, widget.args.item.mainImage),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        widget.args.item.title,
                        style: kHeadersTextStyle,
                      ),
                      Text(
                        getFormattedPrice(widget.args.item.price),
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
                Text(widget.args.item.location.addressDataToString(), style: kBlackHeaderTextStyle,),
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

class RentalScreenArguments {
  Item item;
  RentalScreenArguments({required this.item});
}
