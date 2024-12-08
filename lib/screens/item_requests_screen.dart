import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/models/item_request.dart';
import 'package:rent_app/models/request_status.dart';
import 'package:rent_app/services/query_batch.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import '../constants.dart';
import '../dictionary.dart';
import '../services/cloud_services.dart';
import '../widgets/request_widgets/request_card.dart';

class ItemRequestsScreen extends StatefulWidget {
  static String id = 'item_requests_screen';

  const ItemRequestsScreen({super.key});

  @override
  State<ItemRequestsScreen> createState() => _ItemRequestsScreenState();
}

class _ItemRequestsScreenState extends State<ItemRequestsScreen> with SingleTickerProviderStateMixin {
  final Map<String, ItemRequest> _requestMap = {};
  final Map<String, Item> _itemMap = {};
  final Map<String, TabType> _requestTabMap = {};

  bool _showMyRequests = true;
  late TabController _tabController;
  QueryBatch<ItemRequest> _queryBatch = QueryBatch.empty();
  bool _loading = false;
  bool _streamDataFetched = false;

  StreamSubscription? _itemRequestSubscription;

  void onRequestsTypeClicked(bool showMyRequests) {
    setState(() {
      _showMyRequests = showMyRequests;
    });

    _fetchData();
  }

  TabBar buildStatusTabBar(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return TabBar(
      tabs: TabType.values.map((TabType type) {
        // int count = _requestTabMap.values.where((TabType tabType) => tabType == type).length;
        if (type == TabType.waiting) {
          return Tab(text: localization.waiting_requests);
        } else if (type == TabType.requireAttention) {
          return Tab(text: localization.require_attention_requests);
        } else if (type == TabType.processed) {
          return Tab(text: localization.processed_requests);
        } else {
          return const Tab(text: '');
        }
      }).toList(),
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      controller: _tabController,
    );
  }

  Widget getRequests(TabType tabType) {
    List<MapEntry<String, TabType>> entries = _requestTabMap.entries
        .where((MapEntry<String, TabType> entry) => entry.value == tabType && _requestMap.containsKey(entry.key))
        .toList();

    entries
        .sort((entry1, entry2) => _requestMap[entry1.key]!.time.start.compareTo(_requestMap[entry2.key]!.time.start));

    if (tabType == TabType.processed) {
      entries = entries.reversed.toList();
    }

    List<RequestCard> requests = entries
        .map((MapEntry<String, TabType> entry) => RequestCard(
              key: ValueKey(entry.key),
              request: _requestMap[entry.key]!,
              item: _itemMap[_requestMap[entry.key]!.itemID],
            ))
        .toList();

    return _streamDataFetched ? NotificationListener<ScrollNotification>(
      onNotification: onScroll,
      child: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) => requests[index],
      ),
    ) : Center(child: LoadingAnimationWidget.stretchedDots(color: Colors.grey, size: 50));
  }

  bool onScroll(ScrollNotification scrollInfo) {
    if (_tabController.index != TabType.processed.index) {
      return false;
    }
    var currentScroll = scrollInfo.metrics.pixels;
    var maxScroll = scrollInfo.metrics.maxScrollExtent;
    var offset = MediaQuery.of(context).size.height * 0.5;
    if (currentScroll >= (maxScroll - offset) && !_loading) {
      _fetchPastRequests();
    }
    return false;
  }

  Future<void> _fetchPastRequests() async {
    if (_loading || !_queryBatch.hasMore) return;

    _loading = true;

    _queryBatch = await getPastRequests(!_showMyRequests, _queryBatch.lastDoc);

    _updateData(_queryBatch.list);

    _loading = false;
  }

  Future<void> _updateData(List<ItemRequest> requests) async {
    for (ItemRequest request in requests) {
      _requestMap[request.docRef.id] = request;
      RequestStatus status = getRequestStatus(request);
      if (status == RequestStatus.waiting) {
        _requestTabMap[request.docRef.id] = _showMyRequests ? TabType.waiting : TabType.requireAttention;
      } else if (status == RequestStatus.ownerApproved) {
        _requestTabMap[request.docRef.id] = _showMyRequests ? TabType.requireAttention : TabType.waiting;
      } else {
        _requestTabMap[request.docRef.id] = TabType.processed;
      }
      if (!_itemMap.containsKey(request.itemID)) {
        _itemMap[request.itemID] = await getItemById(request.itemID);
      }
    }
    setState(() {});
  }

  void _fetchData() {
    _itemRequestSubscription?.cancel();
    _requestMap.clear();
    _requestTabMap.clear();
    _itemMap.clear();
    _queryBatch = QueryBatch.empty();
    _streamDataFetched = false;

    _fetchPastRequests();

    _itemRequestSubscription = getFutureRequestsStream(!_showMyRequests).listen((List<ItemRequest> requests) {
      _streamDataFetched = true;
      _updateData(requests);
    });
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: TabType.values.length, vsync: this);

    _fetchData();
  }

  @override
  void dispose() {
    _itemRequestSubscription?.cancel();
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);
    return Scaffold(
      appBar: CustomAppBar(title: localization.requests),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () => onRequestsTypeClicked(true),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(_showMyRequests ? kDarkYellow : kPastelYellowOpacity),
                  ),
                  child: Text(
                    localization.my_requests,
                    style: TextStyle(
                      fontSize: 18,
                      color: _showMyRequests ? Colors.white : kDarkYellow,
                    ),
                  )),
              TextButton(
                  onPressed: () => onRequestsTypeClicked(false),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(_showMyRequests ? kPastelYellowOpacity : kDarkYellow),
                  ),
                  child: Text(
                    localization.requested_from_me,
                    style: TextStyle(
                      fontSize: 18,
                      color: _showMyRequests ? kDarkYellow : Colors.white,
                    ),
                  )),
            ],
          ),
          Container(
            height: 35,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: buildStatusTabBar(context),
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: TabType.values.map(getRequests).toList()),
          ),
        ],
      ),
    );
  }
}

enum TabType {
  waiting,
  requireAttention,
  processed,
}
