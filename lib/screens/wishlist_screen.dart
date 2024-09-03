import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: FutureBuilder(
                    future: getUserItemsByField(userDetails, 'wishlist'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.isNotEmpty) {
                        List? itemCards = snapshot.data;
                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 1,
                          children: itemCards as List<Widget>,
                        );
                      } else {
                        return Container(
                          height: 600,
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            children: [
                              LoadingAnimationWidget.waveDots(
                                  color: Colors.white, size: 10)
                            ],
                          ),
                        );
                      }
                    }),
              ),
            ],
          )),
    ));
  }
}
