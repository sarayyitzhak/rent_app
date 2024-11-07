import 'package:flutter/material.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/item_widgets/item_grid.dart';

import '../constants.dart';

class ItemGridScreen extends StatelessWidget {
  static String id = 'item_grid_screen';

  final ItemGridScreenArguments args;

  const ItemGridScreen(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: args.title, isBackButton: true),
      body: ItemGrid(args.queryBatchGetter)
    );
  }
}

class ItemGridScreenArguments {
  final String title;
  final QueryBatchGetter queryBatchGetter;

  ItemGridScreenArguments(this.title, this.queryBatchGetter);
}
