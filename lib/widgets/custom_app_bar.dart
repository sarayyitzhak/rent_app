import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButton;
  final IconData backIcon;
  final IconData? actionIcon;
  final Function()? onPressed;

  const CustomAppBar({super.key, required this.title, this.isBackButton = true, this.backIcon = Icons.arrow_back, this.actionIcon, this.onPressed});

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              softWrap: false,
            ),
          );
        },
      ),
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
      actions: [
        IconButton(onPressed: onPressed, icon: Icon(actionIcon))
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
