import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/user.dart';
import 'package:rent_app/widgets/chat_icon_button.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/wishlist_icon_button.dart';

import '../services/firebase_services.dart';

class ItemScreen extends StatelessWidget {
  static String id = 'item_screen.dart';
  ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    Item item = arg.item;
    var localization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: '',
          isBackButton: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          child: FutureBuilder(
            future: getItemContactUser(item),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
              return Center(child: Text('Error loading seller details'));
              } else if (snapshot.hasData) {
              UserDetails contactUser = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 60),
                    // child: Image.network(item.imageRef),
                    decoration: BoxDecoration(
                      color: kLightYellow,
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(item.imageRef),
                        fit: BoxFit.fill,
                      ),
                    ),
                    height: 300,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  item.title,
                  style: kBlackHeaderTextStyle,
                ),
                Text(
                  item.description,
                  style: kSmallBlackTextStyle,
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Text(localization.contactUserDetails, style: kBlackHeaderTextStyle,),
                Text(contactUser.name, style: kBlackTextStyle,),
                Text('0${contactUser.phoneNumber}'),
                Text(item.location.addressDataToString(), style: kBlackTextStyle,),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.price}₪',
                      style: kHeadersTextStyle,
                    ),
                    Row(
                      children: [
                        WishlistIconButton(item: item),
                        SizedBox(
                          width: 5,
                        ),
                        ChatIconButton(item: item,),
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization.usersReviews,
                      style: kSmallBlackTextStyle,
                    ),
                    Text('9.8'),
                  ],
                ),
                Center(
                    child: CustomButton(
                        title: localization.rentItem, onPress: () {})),
              ],
            );
    }
            return Container();}

          ),
        ),
      ),
    );
  }
}

class ScreenArguments {
  final Item item;
  ScreenArguments(this.item);
}
