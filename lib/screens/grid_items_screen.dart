import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/models/item.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/services/query_batch.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:rent_app/widgets/item_card.dart';
import '../services/cloud_services.dart';

class GridItemsScreen extends StatefulWidget {
  static String id = 'grid_items_screen';

  final GridItemsScreenArguments args;

  const GridItemsScreen(this.args, {super.key});

  @override
  State<GridItemsScreen> createState() => _GridItemsScreenState();
}

class _GridItemsScreenState extends State<GridItemsScreen> {
  QueryBatch<Item> _queryBatch = QueryBatch.empty();
  final List<ItemCard> _cards = [];
  bool _loading = false;

  Future<void> _fetchItems() async {
    if (_loading || !_queryBatch.hasMore) return;

    setState(() {
      _loading = true;
    });

    _queryBatch = await widget.args.queryBatchGetter(_queryBatch.lastDoc);

    setState(() {
      _cards.addAll(_queryBatch.list.map((Item item) => ItemCard(item: item)).toList());
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.args.title, isBackButton: true),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_loading) {
                  _fetchItems();
                }
                return false;
              },
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) => _cards[index],
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class GridItemsScreenArguments {
  final String title;
  final Future<QueryBatch<Item>> Function([DocumentSnapshot? startAfterDoc]) queryBatchGetter;

  GridItemsScreenArguments(this.title, this.queryBatchGetter);
}
