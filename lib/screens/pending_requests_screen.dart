import 'package:flutter/material.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/models/request_status.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../dictionary.dart';
import '../services/cloud_services.dart';
import '../widgets/request_widgets/scrollable_request_list.dart';

class PendingRequestsScreen extends StatelessWidget {
  static String id = 'pending_requests_screen';

  const PendingRequestsScreen({super.key});

  Future<List<ItemRequest>> getApprovedRequests() async {
    List<ItemRequest> requests = [];

    List<ItemRequest> ownerApprovedRequests = await getApplicantRequestsByStatus(RequestStatus.ownerApproved);
    List<ItemRequest> applicantApprovedRequests = await getApplicantRequestsByStatus(RequestStatus.applicantApproved);

    requests.addAll(ownerApprovedRequests);
    requests.addAll(applicantApprovedRequests);

    return requests;
  }

  Future<List<ItemRequest>> getRejectedRequests() async {
    List<ItemRequest> requests = [];

    List<ItemRequest> applicantRejectedRequests = await getApplicantRequestsByStatus(RequestStatus.applicantRejected);
    List<ItemRequest> ownerRejectedRequests = await getApplicantRequestsByStatus(RequestStatus.ownerRejected);

    requests.addAll(applicantRejectedRequests);
    requests.addAll(ownerRejectedRequests);

    return requests;
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(title: localization.pendingRequests),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('בקשות פגות תוקף'),
            const Divider(),
            Expanded(
              child: ScrollableRequestList(future: getApplicantRequestsByStatus(RequestStatus.expired)),
            ),
            Text(localization.pendingRequests),
            const Divider(),
            Expanded(
              child: ScrollableRequestList(future: getApplicantRequestsByStatus(RequestStatus.waiting)),
            ),
            Text('בקשות שאושרו'),
            const Divider(),
            Expanded(
              child: ScrollableRequestList(future: getApprovedRequests()),
            ),
            Text('בקשות שנדחו'),
            const Divider(),
            Expanded(
              child: ScrollableRequestList(future: getRejectedRequests()),
            ),
          ],
        ),
      ),
    );
  }
}
