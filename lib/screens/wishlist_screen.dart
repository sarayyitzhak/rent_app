import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/scrollable_item_grid.dart';
import '../main.dart';
import '../services/firebase_services.dart';

class WishlistScreen extends StatelessWidget {
  static String id = 'wishlist_screen.dart';
  WishlistScreen({super.key});

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
            child: ScrollableItemGrid(future: getUserItemsByField(userDetails, 'wishlist')),
          ),
        ],
      ),
    ));
  }
}
