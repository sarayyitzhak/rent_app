import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/category.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/address_info.dart';
import 'package:rent_app/screens/home_screen.dart';
import 'package:rent_app/screens/item_screen.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/text_and_text_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import '../models/item.dart';
import '../widgets/custom_button.dart';
import '../widgets/map_dialog.dart';
import '../widgets/pick_image_button.dart';


class AddItemScreen extends StatefulWidget {
  static String id = 'add_item_screen';

  final AddItemScreenArguments args;
  const AddItemScreen(this.args, {super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  Item? item;
  File? image;
  String? imageURLOnEditMode;
  bool isImageChangedOnEditMode = false;
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  Condition? conditionValue;
  late AddressInfo addressValue = AddressInfo(geoPoint: GeoPoint(currentPosition!.latitude, currentPosition!.longitude), addressData: {});
  var _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    priceController = TextEditingController();
    descriptionController = TextEditingController();

    if (widget.args.isEditMode) {
      item = widget.args.item;
      initOnEditMode(widget.args.item);
    }
  }

  void initOnEditMode(Item? item){
    setState(() {
      imageURLOnEditMode = item!.imageRef;
      titleController.text = item.title;
      priceController.text = item.price.toString();
      descriptionController.text = item.description;
      conditionValue = item.condition;
      _selectedCategories = item.categories;
      addressValue = item.location;
    });
  }

  Future<void> mapDialogBuilder(BuildContext context, var localization) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return MapDialog(localization: localization, context: context,
          onPicked: (PickedData pickedData) {
            setState(() {
              addressValue.geoPoint = GeoPoint(pickedData.latLong.latitude, pickedData.latLong.longitude);
              addressValue.addressData = pickedData.addressData;
            });
          });
      },
    );
  }

  Container imageContainer(var localization, bool isEditMode) {
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
            isEditMode && !isImageChangedOnEditMode ? CachedNetworkImage(imageUrl: imageURLOnEditMode.toString(), width: 150, height: 150,
              fit: BoxFit.fill,) :
            image != null
                ? Image.file(
                    image!,
                    width: 150, 
                    height: 150,
                    fit: BoxFit.fill,
                  )
                : Text(localization.noImageSelected),

            PickImageButton(onImagePicked: (newImage){
              setState(() {
                image = newImage;
              });
              if(isEditMode){
                isImageChangedOnEditMode = true;
              }
            },),
          ],
        ));
  }

  MultiSelectBottomSheetField categorySelection(AppLocalizations localization){
    return MultiSelectBottomSheetField(
      decoration: BoxDecoration(
        color: kPastelYellowOpacity,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
      ),
      items: ItemCategory.values
          .map((c) => MultiSelectItem(c, c.getTitle(localization)))
          .toList(),
      initialChildSize: 0.6,
      initialValue: _selectedCategories,
      onConfirm: (values) {
        _selectedCategories = values;
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }

  DropdownMenu<Condition> conditionSelection(AppLocalizations localization){
    return DropdownMenu(
      width: double.infinity,
      onSelected: (value) {
        setState(() {
          conditionValue = value!;
        });
      },
      initialSelection: conditionValue,
      dropdownMenuEntries: Condition.values
          .map((c) =>  DropdownMenuEntry<Condition>(value: c, label: c.getTitle(localization)))
          .toList(),
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: kPastelYellowOpacity,
        hoverColor: kPastelYellowOpacity,
      ),
    );
  }

  Future<void> onAddItemButtonPressed() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing the dialog
      builder: (context) => const Center(child: CircularProgressIndicator(color: kPastelYellow,)),
    );
    createNewItem(image, titleController.text, priceController.text, addressValue, descriptionController.text, conditionValue!, _selectedCategories);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> onEditItemButtonPressed() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing the dialog
      builder: (context) => const Center(child: CircularProgressIndicator(color: kPastelYellow,)),
    );

    await editItem(item!, isImageChangedOnEditMode, image, titleController.text, priceController.text, addressValue, descriptionController.text, conditionValue!, _selectedCategories);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.popAndPushNamed(context, ItemScreen.id, arguments: ItemScreenArguments(item!, true));
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: widget.args.isEditMode ? localization.edit : localization.addItem),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                imageContainer(localization, widget.args.isEditMode),
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
                categorySelection(localization),
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
                    child: conditionSelection(localization),
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
                    // addressValue.addressDataToString(),
                    style: kBlackTextStyle,),
                ),

                const SizedBox(
                  height: 15,
                ),
                widget.args.isEditMode
                    ?  CustomButton(title: localization.edit, onPress: onEditItemButtonPressed)
                    :  CustomButton(title: localization.addItem, onPress: onAddItemButtonPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddItemScreenArguments {
  Item? item;
  bool isEditMode;
  AddItemScreenArguments({this.item, required this.isEditMode});
}