import 'package:flutter/material.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../widgets/request_widgets/request_card.dart';

class RequestListScreen extends StatelessWidget {
  static String id = 'request_list_screen';
  final RequestListScreenArguments args;
  const RequestListScreen(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: args.title),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: ListView(
          children: args.listOfRequests.map((request) => RequestCard(request: request)).toList(),
        )
      ),
    );
  }
}

class RequestListScreenArguments {
  final String title;
  final List<ItemRequest> listOfRequests;

  RequestListScreenArguments(this.title, this.listOfRequests);
}