import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/models/category.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/category_list_tile.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/scrollable_item_grid.dart';
import '../constants.dart';
import '../services/firebase_services.dart';

class SearchResultScreen extends StatefulWidget {
  static String id = 'search_result_screen';
  const SearchResultScreen({super.key});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final _firestore = FirebaseFirestore.instance;
  late TextEditingController searchTextController;
  bool showGrid = false;

  @override
  void initState() {
    super.initState();
  }

  Future<ScrollableItemGrid?> onSearchPressed() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (searchTextController.text.isNotEmpty) {
      setState(() {
        showGrid = true;
      });
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    final arg = ModalRoute.of(context)!.settings.arguments as SearchResultScreenArguments;
    searchTextController = TextEditingController(text: arg.text);
    return Scaffold(
      appBar: CustomAppBar(title: 'חיפוש', isBackButton: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: kTextFieldDecorationOnlyBorder.copyWith(
                            hintText: 'חיפוש'),
                        textInputAction: TextInputAction.search,
                        onEditingComplete: onSearchPressed,
                        controller: searchTextController,
                      ),
                    ),
                    SizedBox.square(
                      dimension: 5,
                    ),
                    CircleAvatar(
                      backgroundColor: kPastelYellow,
                      child: IconButton(
                        onPressed: onSearchPressed,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
               Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: TextButton(
                              onPressed: () {}, child: Text('מיון')),
                          decoration: BoxDecoration(
                            color: kPastelYellowOpacity,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),

                          child: TextButton(
                              onPressed: () {}, child: Text('סינון')),
                          decoration: BoxDecoration(
                            color: kPastelYellowOpacity,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ScrollableItemGrid(
                      future: getItemsFilterByTitle(
                          _firestore, searchTextController.text)),
                ],
              )
                ],
              ),
          ),
        ),
      );
  }
}

class SearchResultScreenArguments{
  String text;
  SearchResultScreenArguments(this.text);
}