import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:rent_app/models/item.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/services/current_position_service.dart';
import 'package:rent_app/services/query_batch.dart';

import '../../constants.dart';
import '../../dictionary.dart';
import '../../screens/item_grid_screen.dart';
import '../../services/bounding_boxing_query.dart';
import '../../services/card_utils.dart';
import '../item_widgets/item_card.dart';
import '../map_dialog.dart';

class AroundYouContainer extends StatefulWidget {
  const AroundYouContainer({super.key});

  @override
  State<AroundYouContainer> createState() => _AroundYouContainerState();
}

class _AroundYouContainerState extends State<AroundYouContainer> {
  late BoundingBoxingQuery _boundingBoxingQuery;

  Widget _getCurrentCityName(BuildContext context) {
    AppLocalizations localization = Dictionary.getLocalization(context);

    if (CurrentPositionService().permission == CurrentPositionPermission.granted) {
      return FutureBuilder(
          future: CurrentPositionService().getCurrentCityName(),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? localization.gettingLocation);
          });
    } else if (CurrentPositionService().permission == CurrentPositionPermission.denied) {
      return Text(localization.no_permission);
    } else if (CurrentPositionService().permission == CurrentPositionPermission.serviceDisabled) {
      return Text(localization.location_services_are_turned_off);
    }
    return Text(localization.please_wait);
  }

  Widget _getChangeLocationAction(BuildContext context) {
    AppLocalizations localization = Dictionary.getLocalization(context);

    if (CurrentPositionService().permission == CurrentPositionPermission.granted) {
      return TextButton(
        onPressed: _openMapDialog,
        child: Text(localization.change_location),
      );
    } else if (CurrentPositionService().permission == CurrentPositionPermission.denied) {
      return TextButton(
        onPressed: CurrentPositionService().requestPermission,
        child: Text(localization.grant_permission),
      );
    } else if (CurrentPositionService().permission == CurrentPositionPermission.serviceDisabled) {
      return TextButton(
        onPressed: CurrentPositionService().openLocationSettings,
        child: Text(localization.open_location_settings),
      );
    }
    return Container();
  }

  void _openMapDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapDialog(
            context: context,
            onPicked: (PickedData pickedData) {
              GeoPoint geoPoint = GeoPoint(pickedData.latLong.latitude, pickedData.latLong.longitude);
              CurrentPositionService().updateGeoPoint(geoPoint);
            });
      },
    );
  }

  Future<QueryBatch<Item>> _getAroundYouItems([DocumentSnapshot? startAfterDoc]) async {
    _boundingBoxingQuery = await getItemsByGeoPoint(
        CurrentPositionService().geoPoint!, _boundingBoxingQuery.currentDistance, startAfterDoc);
    return _boundingBoxingQuery;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = Dictionary.getLocalization(context);

    return ListenableBuilder(
        listenable: CurrentPositionService().currentPositionNotifier,
        builder: (BuildContext context, Widget? child) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        localization.aroundYou,
                        style: kBlackHeaderTextStyle,
                      ),
                      const Icon(Icons.location_on_outlined),
                      _getCurrentCityName(context),
                      _getChangeLocationAction(context),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _boundingBoxingQuery = BoundingBoxingQuery.empty();
                      Navigator.pushNamed(context, ItemGridScreen.id,
                          arguments: ItemGridScreenArguments(localization.aroundYou, _getAroundYouItems));
                    },
                    child: Text(
                      localization.show_more,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 250,
                child: CurrentPositionService().geoPoint == null
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: kPastelYellow,
                      ))
                    : FutureBuilder(
                        future: getItemsByGeoPoint(CurrentPositionService().geoPoint!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            QueryBatch<Item> items = snapshot.data!;
                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children:
                                  items.list.map((Item item) => ItemCard(item: item, isHorizontal: true)).toList(),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
              )
            ],
          );
        });
  }
}
