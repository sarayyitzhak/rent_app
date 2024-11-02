import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/scrollable_item_grid.dart';
import '../constants.dart';
import '../services/card_utils.dart';

class SearchResultScreen extends StatefulWidget {
  static String id = 'search_result_screen';

  final SearchResultScreenArguments args;
  const SearchResultScreen(this.args, {super.key});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late TextEditingController searchTextController;
  late ScrollableItemGrid itemGrid;

  @override
  void initState() {
    super.initState();

    searchTextController = TextEditingController(text: widget.args.text);
    itemGrid = ScrollableItemGrid(future: getItemsFilterByTitle(searchTextController.text, false));
  }

  Future<ScrollableItemGrid?> onSearchPressed() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (searchTextController.text.isNotEmpty) {
      setState(() {
        itemGrid = ScrollableItemGrid(future: getItemsFilterByTitle(searchTextController.text, false));
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: localization.search, isBackButton: false),
      body: Padding(
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
                          hintText: localization.search),
                      textInputAction: TextInputAction.search,
                      onEditingComplete: onSearchPressed,
                      controller: searchTextController,
                    ),
                  ),
                  const SizedBox.square(
                    dimension: 5,
                  ),
                  CircleAvatar(
                    backgroundColor: kPastelYellow,
                    child: IconButton(
                      onPressed: onSearchPressed,
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: kPastelYellowOpacity,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                              onPressed: () {}, child: Text(localization.sort)),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: kPastelYellowOpacity,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                              onPressed: () {},
                              child: Text(localization.filter)),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: itemGrid,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SearchResultScreenArguments {
  String text;

  SearchResultScreenArguments(this.text);
}
