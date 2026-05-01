import 'package:rent_app/constants.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/request_widgets/scrollable_request_list.dart';
import '../dictionary.dart';
import '../services/cloud_services.dart';
import '../services/card_utils.dart';
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

  void onOnlyRequestsPressed() {
    setState(() {
      showAllItems = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg != null) {
        if ((arg as UserItemsScreenArguments).showRequests) {
          onOnlyRequestsPressed();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(title: localization.myItems, isBackButton: false),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: onAllItemsPressed,
                  style: showAllItems
                      ? kSmallButtonClickedStyle
                      : kSmallButtonStyle,
                  child: Text(localization.allItems)),
              TextButton(
                  onPressed: onOnlyRequestsPressed,
                  style: !showAllItems
                      ? kSmallButtonClickedStyle
                      : kSmallButtonStyle,
                  child: Text(localization.pendingRequests)),
            ],
          ),
          showAllItems
              ? Expanded(
                  child: StreamBuilder(
                    stream: getUserItemsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final itemCards =
                          getItemsByStream(snapshot.data?.docs, false);
                      if (itemCards.isEmpty) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              localization.emptyItems,
                              textAlign: TextAlign.center,
                              style: kBlackHeaderTextStyle,
                            ),
                          ),
                        );
                      }
                      return DynamicScrollableItemGrid(
                        stream: getUserItemsStream(),
                      );
                    },
                  ),
                )
              : Expanded(
                  child: ScrollableRequestList(
                  future: getUserRequestsStream(),
                  emptyText: localization.noPendingRequests,
                  emptyTextStyle: kBlackHeaderTextStyle,
                )),
        ],
      ),
      floatingActionButton: CustomButton(
          title: localization.addItem,
          onPress: () {
            Navigator.pushNamed(context, AddItemScreen.id,
                arguments: AddItemScreenArguments(isEditMode: false));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class UserItemsScreenArguments {
  bool showRequests;
  UserItemsScreenArguments({this.showRequests = false});
}
