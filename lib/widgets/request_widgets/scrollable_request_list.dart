import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rent_app/widgets/request_widgets/request_card.dart';
import '../../models/item_request.dart';

class ScrollableRequestList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (stream != null) {
      return StreamBuilder<List<ItemRequest>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty && emptyText != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      emptyText!,
                      textAlign: TextAlign.center,
                      style: emptyTextStyle,
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

    return FutureBuilder(future: future, builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data!.isEmpty && emptyText != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                emptyText!,
                textAlign: TextAlign.center,
                style: emptyTextStyle,
              ),
            ),
          );
        }
        return ListView(
          children: snapshot.data!.map((request) => RequestCard(request: request)).toList(),
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
