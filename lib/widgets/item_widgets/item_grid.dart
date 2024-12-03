import 'package:rent_app/models/item.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/services/query_batch.dart';
import 'package:rent_app/widgets/item_widgets/item_card.dart';

import '../../constants.dart';

class ItemGrid extends StatefulWidget {
  final QueryBatchGetterNotifier queryBatchGetterNotifier;

  ItemGrid(QueryBatchGetter queryBatchGetter, {super.key, QueryBatchGetterNotifier? notifier}) : queryBatchGetterNotifier = notifier ?? QueryBatchGetterNotifier() {
    queryBatchGetterNotifier.queryBatchGetter = queryBatchGetter;
  }

  @override
  State<ItemGrid> createState() => _ItemGridState();
}

class _ItemGridState extends State<ItemGrid> {
  QueryBatch<Item> _queryBatch = QueryBatch.empty();
  final List<ItemCard> _cards = [];
  bool _loading = false;

  bool onScroll(ScrollNotification scrollInfo) {
    var currentScroll = scrollInfo.metrics.pixels;
    var maxScroll = scrollInfo.metrics.maxScrollExtent;
    var offset = MediaQuery.of(context).size.height * 0.5;
    if (currentScroll >= (maxScroll - offset) && !_loading) {
      _fetchItems();
    }
    return false;
  }

  Future<void> _fetchItems() async {
    if (_loading || !_queryBatch.hasMore) return;

    _loading = true;

    if (_cards.isEmpty) {
      _cards.addAll(List.generate(8, (_) => const ItemCard()));
    }

    _queryBatch = await widget.queryBatchGetterNotifier.queryBatchGetter(_queryBatch.lastDoc);

    setState(() {
      if (_cards.isNotEmpty) {
        _cards.removeWhere((ItemCard card) => card.item == null);
      }

      _cards.addAll(_queryBatch.list.map((Item item) => ItemCard(item: item)).toList());

      if (_queryBatch.hasMore) {
        _cards.addAll(List.generate(2 + (_cards.length % 2), (_) => const ItemCard()));
      }
    });

    _loading = false;
  }

  void _onQueryBatchGetterChanged() {
    _queryBatch = QueryBatch.empty();
    _cards.clear();
    _fetchItems();
  }

  @override
  void initState() {
    super.initState();

    _fetchItems();
    widget.queryBatchGetterNotifier.addListener(_onQueryBatchGetterChanged);
  }

  @override
  void dispose() {
    super.dispose();

    widget.queryBatchGetterNotifier.removeListener(_onQueryBatchGetterChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: onScroll,
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
      ],
    );
  }
}

class QueryBatchGetterNotifier extends ChangeNotifier {
  late QueryBatchGetter queryBatchGetter;

  void updateQueryBatchGetter(QueryBatchGetter queryBatchGetter) {
    this.queryBatchGetter = queryBatchGetter;
    notifyListeners();
  }
}
