import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:rent_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/item_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../constants.dart';
import 'package:rent_app/widgets/custom_button.dart';
import '../main.dart';
import '../services/firebase_services.dart';

class UserItemsScreen extends StatefulWidget {
  static String id = 'user_items_screen';
  const UserItemsScreen({super.key});

  @override
  State<UserItemsScreen> createState() => _UserItemsScreenState();
}

class _UserItemsScreenState extends State<UserItemsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final storageRef = FirebaseStorage.instance.ref();

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return SafeArea(
        child: Scaffold(
      appBar: CustomAppBar(title: localization.myItems, isBackButton: false),
      body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: FutureBuilder(
                    future: getItemsByField(userDetails, 'items'),
                    initialData: [
                      Container(
                          height: 600,
                          child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              children: [
                                LoadingAnimationWidget.waveDots(
                                    color: Colors.white, size: 10)
                              ]))
                    ],
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                    title: localization.addItem,
                    onPress: () {
                      Navigator.pushNamed(context, AddItemScreen.id);
                    }),
              )
            ],
          )),
    ));
  }
}
