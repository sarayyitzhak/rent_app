import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import '../screens/home_screen.dart';

class MapDialog extends StatelessWidget {
  final BuildContext context;
  final AppLocalizations localization;
  final Function(PickedData pickedData) onPicked;
  const MapDialog({super.key, required this.context, required this.localization, required this.onPicked});

  @override
  Widget build(BuildContext context) {
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
          initPosition: LatLong(currentPosition?.latitude ?? 23, currentPosition?.longitude ?? 25),
          selectLocationButtonStyle: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.blue),
          ),
          selectedLocationButtonTextStyle: const TextStyle(fontSize: 18),
          selectLocationButtonText: localization.select,
          selectLocationButtonLeadingIcon: const Icon(Icons.check),
          initZoom: 11,
          minZoomLevel: 5,
          maxZoomLevel: 16,
          trackMyPosition: true,
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
