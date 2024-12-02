import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:rent_app/globals.dart';

import '../dictionary.dart';
import '../services/current_position_service.dart';

class MapDialog extends StatelessWidget {
  final BuildContext context;
  final Function(PickedData pickedData) onPicked;
  const MapDialog({super.key, required this.context, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = Dictionary.getLocalization(context);

    return AlertDialog(
      title: Text(localization.pleaseChooseLocation),
      insetPadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(8),
      content: SizedBox(
        height: 600,
        width: MediaQuery.of(context).size.width - 40,
        child: FlutterLocationPicker(
          searchBarHintText: localization.searchLocation,
          urlTemplate: kMapUrl,
          mapLanguage: localization.language,
          initPosition: LatLong(CurrentPositionService().geoPoint?.latitude ?? 23, CurrentPositionService().geoPoint?.longitude ?? 25),
          selectLocationButtonStyle: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.blue),
          ),
          selectedLocationButtonTextStyle: const TextStyle(fontSize: 18),
          selectLocationButtonText: localization.select,
          selectLocationButtonLeadingIcon: const Icon(Icons.check),
          initZoom: 16,
          minZoomLevel: 5,
          maxZoomLevel: 18,
          onError: (e) => print(e),
          onPicked: (pickedData) {
            onPicked(pickedData);
            Navigator.of(context).pop();
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }
}
