import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:rent_app/services/current_position_service.dart';

import '../../constants.dart';
import '../../dictionary.dart';
import '../../services/card_utils.dart';
import '../map_dialog.dart';

class AroundYouContainer extends StatefulWidget {
  const AroundYouContainer({super.key});

  @override
  State<AroundYouContainer> createState() => _AroundYouContainerState();
}

class _AroundYouContainerState extends State<AroundYouContainer> {
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
      return OutlinedButton(
        onPressed: CurrentPositionService().requestPermission,
        child: Text(localization.grant_permission),
      );
    } else if (CurrentPositionService().permission == CurrentPositionPermission.serviceDisabled) {
      return OutlinedButton(
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

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = Dictionary.getLocalization(context);

    return ListenableBuilder(
        listenable: CurrentPositionService().currentPositionNotifier,
        builder: (BuildContext context, Widget? child) {
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    localization.aroundYou,
                    style: kBlackHeaderTextStyle,
                  ),
                  const Icon(Icons.location_on_outlined),
                  _getCurrentCityName(context),
                  _getChangeLocationAction(context)
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
                        future: getItemsFilterByGeoPoint(CurrentPositionService().geoPoint!.latitude,
                            CurrentPositionService().geoPoint!.longitude, true),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                            List? itemCards = snapshot.data;
                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children: itemCards as List<Widget>,
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
