import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButton;
  final IconData backIcon;

  const CustomAppBar({super.key, required this.title, this.isBackButton = true, this.backIcon = Icons.arrow_back});

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Text(title),
      titleTextStyle: kTopHeaderTextStyle,
      centerTitle: true,
      leading: isBackButton
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(backIcon),
            )
          : null,
      automaticallyImplyLeading: isBackButton,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
