import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/request_widgets/scrollable_request_list.dart';
import '../services/cloud_services.dart';
import '../widgets/dynamic_scrollable_item_grid.dart';

class UserItemsScreen extends StatefulWidget {
  static String id = 'user_items_screen';
  const UserItemsScreen({super.key});

  @override
  State<UserItemsScreen> createState() => _UserItemsScreenState();
}

class _UserItemsScreenState extends State<UserItemsScreen> {
  bool showAllItems = true;

  void onAllItemsPressed() {
    setState(() {
      showAllItems = true;
    });
  }

  void onOnlyRequestsPressed(){
    setState(() {
      showAllItems = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if(arg != null){
        if((arg as UserItemsScreenArguments).showRequests){
          onOnlyRequestsPressed();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return SafeArea(
        child: Scaffold(
      appBar: CustomAppBar(title: localization.myItems, isBackButton: false),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: onAllItemsPressed,
                  style: kSmallButtonStyle,
                  child: Text(localization.allItems)),
              TextButton(
                  onPressed: onOnlyRequestsPressed,
                  style: kSmallButtonStyle,
                  child: Text(localization.pendingRequests)),
            ],
          ),
          showAllItems 
              ? Expanded(
              child: DynamicScrollableItemGrid(
            stream: getUserItemsStream(),
          ))
          : Expanded(child: ScrollableRequestList(future: getUserRequestsStream())),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
                title: localization.addItem,
                onPress: () {
                  Navigator.pushNamed(context, AddItemScreen.id, arguments: AddItemScreenArguments(isEditMode: false));
                }),
          )
        ],
      ),
    ));
  }
}

class UserItemsScreenArguments{
  bool showRequests;
  UserItemsScreenArguments({this.showRequests = false});
}