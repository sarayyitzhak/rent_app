import 'dart:async';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/category.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/address_info.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/text_and_text_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

import '../main.dart';
import '../models/item.dart';
import '../widgets/pick_image_button.dart';


class AddItemScreen extends StatefulWidget {
  static String id = 'add_item_screen';

  const AddItemScreen({super.key});
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  File? image;
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late Condition conditionValue;
  late AddressInfo addressValue =
      AddressInfo(latitude: 0, longitude: 0, addressData: {'city': '', 'road': ''});
  var _selectedCategories = [];
  final List<MultiSelectItem<ItemCategory>> _categoryItems = ItemCategory.values
      .map((category) => MultiSelectItem<ItemCategory>(category, category.toString().split('.').last))
      .toList();


  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    priceController = TextEditingController();
    descriptionController = TextEditingController();
    addressController = TextEditingController();
    _getUserLocation();
  }


  GoogleMapController? mapController;
  LatLng _initialPosition = const LatLng(37.7749, -122.4194); // Default position
  String _pickedAddress = "Search for an address";

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _onPlaceSelected(LatLng latLng, String address) {
    setState(() {
      _initialPosition = latLng;
      _pickedAddress = address;
      mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }


  Future<void> mapDialogBuilder(BuildContext context, var localization) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.pleaseChooseLocation),
          insetPadding: const EdgeInsets.all(0),
          contentPadding: const EdgeInsets.all(8),
          content: SizedBox(
            height: 600,
            width: MediaQuery.of(context).size.width - 40,
            // width: double.infinity,
            child: FlutterLocationPicker(
                searchBarHintText: localization.searchLocation,
                urlTemplate: kMapUrl,
                mapLanguage: localization.language,
                initPosition: const LatLong(23, 89),
                selectLocationButtonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                ),
                selectedLocationButtonTextStyle: const TextStyle(fontSize: 18),
                selectLocationButtonText: 'מרכוז',
                selectLocationButtonLeadingIcon: const Icon(Icons.check),
                initZoom: 11,
                minZoomLevel: 5,
                maxZoomLevel: 16,
                trackMyPosition: true,
                onError: (e) => print(e),
                onPicked: (pickedData) {
                  setState(() {
                    addressValue.latitude = pickedData.latLong.latitude;
                    addressValue.longitude = pickedData.latLong.longitude;
                    addressValue.addressData = pickedData.addressData;
                  });
                },
                onChanged: (pickedData) {
                  setState(() {
                    addressValue.latitude = pickedData.latLong.latitude;
                    addressValue.longitude = pickedData.latLong.longitude;
                    addressValue.addressData = pickedData.addressData;
                  });
                }),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
                backgroundColor: kPastelYellow
              ),
              child: Text(localization.set),
              onPressed: () {
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        );
      },
    );
  }



  Container buildImageContainer(var localization) {
    return Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kPastelYellowOpacity,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image != null
                ? Image.file(
                    image!,
                    width: 150, // specify desired width
                    height: 150, // specify desired height
                    fit: BoxFit.fill,
                  )
                : Text(localization.noImageSelected),
            PickImageButton(onImagePicked: (newImage){
              setState(() {
                image = newImage;
              });
            },),
          ],
        ));
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> onAddItemButtonPressed() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing the dialog
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: kPastelYellow,),
        );
      },
    );
    createNewItem(image, titleController.text, priceController.text, addressValue, descriptionController.text, conditionValue, _selectedCategories);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: localization.addItem),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildImageContainer(localization),
                TextAndTextField(
                    title: localization.title, controller: titleController),
                TextAndTextField(
                  title: localization.price,
                  controller: priceController,
                  keyboardType: TextInputType.number,
                ),

                Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      localization.category,
                      style: kBlackTextStyle,
                    )),
                MultiSelectBottomSheetField(
                  decoration: BoxDecoration(
                    color: kPastelYellowOpacity,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  items: ItemCategory.values
                      .map((e) => MultiSelectItem(e, e.getTitle(localization)))
                      .toList(),
                  initialChildSize: 0.6,
                  initialValue: _selectedCategories,
                  onConfirm: (values) {
                    _selectedCategories = values;
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
                const SizedBox(
                  height: 20,
                ),

                Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      localization.condition,
                      style: kBlackTextStyle,
                    )),
                Container(
                  decoration: BoxDecoration(
                    color: kPastelYellowOpacity,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownMenu(
                      width: double.infinity,
                      onSelected: (value) {
                        setState(() {
                          conditionValue = value!;
                        });
                      },
                      dropdownMenuEntries: [
                        DropdownMenuEntry<Condition>(
                            value: Condition.NEW,
                            label: Condition.NEW.getTitle(localization)),
                        DropdownMenuEntry<Condition>(
                            value: Condition.USED_AS_NEW,
                            label: Condition.USED_AS_NEW.getTitle(localization)),
                        DropdownMenuEntry<Condition>(
                            value: Condition.USED_IN_GOOD_SHAPE,
                            label: Condition.USED_IN_GOOD_SHAPE.getTitle(localization)),
                        DropdownMenuEntry<Condition>(
                            value: Condition.USED_IN_MEDIUM_SHAPE,
                            label: Condition.USED_IN_MEDIUM_SHAPE.getTitle(localization)),
                      ],
                      inputDecorationTheme: const InputDecorationTheme(
                        fillColor: kPastelYellowOpacity,
                        hoverColor: kPastelYellowOpacity,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                TextAndTextField(
                  title: localization.description,
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: true,
                ),

                // TextAndTextField(
                //   title: localization.address,
                //   controller: addressController,
                //   onTapped: () => mapDialogBuilder(context, localization),
                // ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    localization.address,
                    style: kBlackTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () => mapDialogBuilder(context, localization),
                  style: kAddressButtonStyle,
                  child: Text(
                    addressValue.addressDataToString(),
                      // '${addressValue.addressData['city']}${addressValue.addressData['road'] != null ? ',  ${addressValue.addressData['road']}' : ''}',
                    style: kBlackTextStyle,),
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomButton(title: localization.addItem, onPress: onAddItemButtonPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
