import 'package:flutter/material.dart';
import 'package:rent_app/models/request_status.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../dictionary.dart';
import '../services/cloud_services.dart';
import '../widgets/request_widgets/scrollable_request_list.dart';

class RentalHistoryScreen extends StatelessWidget {
  static String id = 'rental_history_screen';
  const RentalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: 'היסטורית השכרות'),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScrollableRequestList(future: getHistoryRequests()),
          ],
        ),
      ),
    );
  }
}
