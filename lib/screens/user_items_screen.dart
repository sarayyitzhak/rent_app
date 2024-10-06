import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/screens/add_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/scrollable_item_grid.dart';
import '../main.dart';
import '../services/firebase_services.dart';
import '../widgets/dynamic_scrollable_item_grid.dart';

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

  void refreshScreen(){
    setState(() {
      userDetails.userReference;
    });
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
          Expanded(child: DynamicScrollableItemGrid(stream: _firestore.collection('items').where(
              'contactUser', isEqualTo: userDetails.userReference).orderBy('createdAt', descending: true).snapshots(),)),
          // Expanded(child: ScrollableItemGrid(future: getItemsFilterByContactUser(_firestore, userDetails.userReference))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
                title: localization.addItem,
                onPress: () {
                  Navigator.pushNamed(context, AddItemScreen.id);
                }),
          )
        ],
      ),
    ));
  }
}
