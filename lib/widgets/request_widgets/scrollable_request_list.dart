import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/widgets/request_widgets/request_card.dart';

import '../../models/item_request.dart';

class ScrollableRequestList extends StatefulWidget {
  final Future<List<ItemRequest>>? future;
  final Stream<List<ItemRequest>>? stream;
  final String? emptyText;
  final TextStyle? emptyTextStyle;

  const ScrollableRequestList(
      {super.key,
      this.future,
      this.stream,
      this.emptyText,
      this.emptyTextStyle})
      : assert(future != null || stream != null,
            'Provide either future or stream');

  @override
  State<ScrollableRequestList> createState() => _ScrollableRequestListState();
}

class _ScrollableRequestListState extends State<ScrollableRequestList> {
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  final List<ItemRequest> _requests = [];
  StreamSubscription<List<ItemRequest>>? _subscription;
  bool _loadingStream = true;
  bool _streamInitialized = false;

  @override
  void initState() {
    super.initState();
    _attachStream();
  }

  @override
  void didUpdateWidget(covariant ScrollableRequestList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _attachStream();
    }
  }

  void _attachStream() {
    _subscription?.cancel();
    if (widget.stream == null) {
      return;
    }

    _loadingStream = true;
    _streamInitialized = false;
    _requests.clear();

    _subscription = widget.stream!.listen((incoming) {
      if (!_streamInitialized) {
        _requests.addAll(incoming);
        _streamInitialized = true;
        if (mounted) {
          setState(() {
            _loadingStream = false;
          });
        }
        return;
      }

      _animateDiff(incoming);
      if (mounted && _loadingStream) {
        setState(() {
          _loadingStream = false;
        });
      }
    });
  }

  void _animateDiff(List<ItemRequest> incoming) {
    final Set<String> incomingIds = incoming.map((r) => r.docRef.id).toSet();

    for (int i = _requests.length - 1; i >= 0; i--) {
      if (!incomingIds.contains(_requests[i].docRef.id)) {
        final removedItem = _requests.removeAt(i);
        _animatedListKey.currentState?.removeItem(
          i,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: animation,
              child: RequestCard(request: removedItem),
            ),
          ),
          duration: const Duration(milliseconds: 280),
        );
      }
    }

    final Map<String, ItemRequest> currentById = {
      for (final r in _requests) r.docRef.id: r
    };
    final List<ItemRequest> newList = [];
    for (final item in incoming) {
      newList.add(currentById[item.docRef.id] ?? item);
    }

    if (mounted) {
      setState(() {
        _requests
          ..clear()
          ..addAll(newList);
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stream != null) {
      if (_loadingStream) {
        return Center(
          child: LoadingAnimationWidget.stretchedDots(
              color: Colors.grey, size: 50),
        );
      }

      if (_requests.isEmpty && widget.emptyText != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              widget.emptyText!,
              textAlign: TextAlign.center,
              style: widget.emptyTextStyle,
            ),
          ),
        );
      }

      return AnimatedList(
        key: _animatedListKey,
        initialItemCount: _requests.length,
        itemBuilder: (context, index, animation) {
          return SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: animation,
              child: RequestCard(request: _requests[index]),
            ),
          );
        },
      );
    }

    return FutureBuilder<List<ItemRequest>>(
        future: widget.future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty && widget.emptyText != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    widget.emptyText!,
                    textAlign: TextAlign.center,
                    style: widget.emptyTextStyle,
                  ),
                ),
              );
            }
            return ListView(
              children: snapshot.data!
                  .map((request) => RequestCard(request: request))
                  .toList(),
            );
          } else {
            return Center(
              child: LoadingAnimationWidget.stretchedDots(
                  color: Colors.grey, size: 50),
            );
          }
        });
  }
}
