import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../dictionary.dart';
import '../services/cloud_services.dart';
import '../widgets/request_widgets/scrollable_request_list.dart';

class PendingRequestsScreen extends StatelessWidget {
  static String id = 'pending_requests_screen';
  const PendingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: localization.pendingRequests),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScrollableRequestList(future: getPendingRequestsStream()),
          ],
        ),
      ),
    );
  }
}
