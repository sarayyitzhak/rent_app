import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/models/request_status.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ExtensionRequestDialog extends StatefulWidget {
  static String id = 'request_screen';

  final ItemRequest itemRequest;

  const ExtensionRequestDialog({super.key, required this.itemRequest});

  @override
  State<ExtensionRequestDialog> createState() => _ExtensionRequestDialogState();
}

class _ExtensionRequestDialogState extends State<ExtensionRequestDialog> {
  final DateRangePickerController _controller = DateRangePickerController();
  bool isInvalidDate = false;

  void onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (_controller.selectedRange?.endDate == null) {
      return;
    }
    setState(() {
      isInvalidDate = !widget.itemRequest.time.end.isBefore(_controller.selectedRange!.endDate!);
    });
  }

  void onChoosePressed(BuildContext context) {
    if (_controller.selectedRange?.endDate == null) {
      return;
    }

    setState(() {
      isInvalidDate = !widget.itemRequest.time.end.isBefore(_controller.selectedRange!.endDate!);
    });

    if (isInvalidDate) {
      return;
    }
    updateExtensionRequest(widget.itemRequest.docRef, _controller.selectedRange!.endDate!);
    Navigator.pop(context);
  }

  void onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder(
        future: getFutureItemRequests(widget.itemRequest.itemID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DateTime> waitingDates = [];
            DateTime? maxDate;

            for (ItemRequest itemRequest in snapshot.data!) {
              if (itemRequest.status == RequestStatus.WAITING) {
                waitingDates.addAll(getDateList(itemRequest.time));
              } else if (itemRequest.status == RequestStatus.APPROVED) {
                var startDate = itemRequest.time.start.subtract(const Duration(days: 1));
                if (startDate.isAfter(widget.itemRequest.time.end)) {
                  if (maxDate == null || startDate.isBefore(maxDate)) {
                    maxDate = startDate;
                  }
                }
                if (itemRequest.extensionRequest != null && itemRequest.extensionRequest!.status == RequestStatus.WAITING) {
                  var start = itemRequest.time.end.add(const Duration(days: 1));
                  var end = itemRequest.extensionRequest!.toDate;
                  waitingDates.addAll(getDateList(DateTimeRange(start: start, end: end)));
                }
              }
            }

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'בחר תאריך סיום',
                    style: kBlackHeaderTextStyle,
                  ),
                  SfDateRangePicker(
                    controller: _controller,
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.extendableRange,
                    extendableRangeSelectionDirection: ExtendableRangeSelectionDirection.forward,
                    initialSelectedRange: PickerDateRange(widget.itemRequest.time.start, widget.itemRequest.time.end),
                    enablePastDates: false,
                    maxDate: maxDate,
                    todayHighlightColor: Colors.blue,
                    backgroundColor: Colors.transparent,
                    selectionColor: Colors.blue,
                    onSelectionChanged: onSelectionChanged,
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                    ),
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
                      disabledDatesTextStyle: TextStyle(color: Colors.grey),
                      blackoutDatesDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      blackoutDateTextStyle: TextStyle(color: Colors.grey),
                      specialDatesDecoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      enableSwipeSelection: false,
                      specialDates: waitingDates,
                    ),
                  ),
                  isInvalidDate
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'יש לבחור תאריך מאוחר יותר מ- ${dateToString(widget.itemRequest.time.end)}',
                              style: TextStyle(fontSize: 14, color: Colors.red),
                            ),
                          ],
                        )
                      : Container(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => onChoosePressed(context),
                        child: Text("בחר"),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => onCancelPressed(context),
                        child: Text("ביטול"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [LoadingAnimationWidget.stretchedDots(color: Colors.grey, size: 50)]));
          }
        },
      ),
    );
  }
}
