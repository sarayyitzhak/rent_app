import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/models/category.dart';
import 'package:rent_app/screens/search_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/category_list_tile.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/scrollable_item_grid.dart';
import '../constants.dart';

class SearchScreen extends StatefulWidget {
  static String id = 'search_screen';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;

  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();
  }

  Future<ScrollableItemGrid?> onSearchPressed() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (searchTextController.text.isNotEmpty) {
      String text = searchTextController.text;
      searchTextController.clear();
      Navigator.pushNamed(context, SearchResultScreen.id, arguments: SearchResultScreenArguments(text));
    }
    return null;
  }

  Column buildCategoryListTiles() {
    List<CategoryListTile> tiles = [];
    for (var category in ItemCategory.values) {
      tiles.add(CategoryListTile(category: category));
    }
    return Column(
      children: tiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return SafeArea(
        child: Scaffold(
      appBar: CustomAppBar(title: 'חיפוש', isBackButton: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
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
              Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'או חפש לפי קטגוריות',
                          style: kBlackHeaderTextStyle,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        buildCategoryListTiles(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    ));
  }
}
