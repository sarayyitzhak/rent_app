import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/dynamic_scrollable_item_grid.dart';
import 'package:rent_app/widgets/scrollable_item_grid.dart';
import '../main.dart';
import '../services/card_utils.dart';
import '../services/cloud_services.dart';

class WishlistScreen extends StatelessWidget {
  static String id = 'wishlist_screen.dart';
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return SafeArea(
        child: Scaffold(
      appBar: CustomAppBar(title: localization.wishlist, isBackButton: false),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ScrollableItemGrid(future: getUserItemsWishlist(userDetails, false, false)),
          ),
        ],
      ),
    ));
  }
}
