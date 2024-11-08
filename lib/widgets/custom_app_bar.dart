import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  String title;
  bool isBackButton;
  CustomAppBar({super.key, required this.title, this.isBackButton = true});

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Text(title),
      titleTextStyle: kTopHeaderTextStyle,
      centerTitle: true,
      leading: isBackButton ? IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ) : null,
      automaticallyImplyLeading: this.isBackButton,
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// AppBar(
// title: Text(localization.createAccount),
// titleTextStyle: kTopHeaderTextStyle,
// centerTitle: true,
// leading: IconButton(
// onPressed: () {
// Navigator.pop(context);
// },
// icon: Icon(Icons.arrow_back),
// ),
// ),