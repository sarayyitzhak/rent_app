import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/globals.dart';
import 'package:rent_app/models/category.dart';
import 'package:rent_app/models/condition.dart';
import 'package:rent_app/models/address_info.dart';
import 'package:rent_app/models/file_data.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:rent_app/utils.dart';
import 'package:rent_app/widgets/add_item_widgets/selectable_images_container.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/text_and_text_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import '../models/item.dart';
import '../widgets/custom_button.dart';
import '../widgets/map_dialog.dart';

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
  bool isImageChangedOnEditMode = false;
  late SelectingImagesController imagesController;
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  Condition? conditionValue;
  late AddressInfo addressValue =
      AddressInfo(geoPoint: GeoPoint(currentPosition!.latitude, currentPosition!.longitude), city: '', road: '');
  List<ItemCategory> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    imagesController = SelectingImagesController();
    titleController = TextEditingController();
    priceController = TextEditingController();
    descriptionController = TextEditingController();

    if (widget.args.isEditMode) {
      item = widget.args.item;
      initOnEditMode(widget.args.item);
    }
  }

  void initOnEditMode(Item? item) {
    initImages();
    setState(() {
      titleController.text = item!.title;
      priceController.text = item.price.toString();
      descriptionController.text = item.description;
      conditionValue = item.condition;
      _selectedCategories = item.categories;
      addressValue = item.location;
    });
  }

  Future<void> initImages() async {
    List<Reference> imageRefList = await getFileReferences(getItemImageDirRef(item!.docRef));
    for (int i = 0; i < imageRefList.length; i++) {
      FileData fileData = await getFileData(imageRefList[i]);
      if (fileData.exists) {
        setState(() {
          imagesController.images.add(fileData);
          if (item!.mainImage == fileData.name) {
            imagesController.mainImage = fileData;
          }
        });
      }
    }
  }

  Future<void> mapDialogBuilder(BuildContext context, var localization) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return MapDialog(
            localization: localization,
            context: context,
            onPicked: (PickedData pickedData) {
              setState(() {
                addressValue = AddressInfo(
                    geoPoint: GeoPoint(pickedData.latLong.latitude, pickedData.latLong.longitude),
                    city: pickedData.addressData['city'],
                    road: pickedData.addressData['road']);
              });
            });
      },
    );
  }

  MultiSelectBottomSheetField categorySelection(AppLocalizations localization) {
    return MultiSelectBottomSheetField(
      decoration: BoxDecoration(
        color: kPastelYellowOpacity,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
      ),
      items: ItemCategory.values.map((c) => MultiSelectItem(c, c.getTitle(localization))).toList(),
      initialChildSize: 0.6,
      initialValue: _selectedCategories,
      onConfirm: (values) {
        _selectedCategories = values.map((val) => val as ItemCategory).toList();
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }

  DropdownMenu<Condition> conditionSelection(AppLocalizations localization) {
    return DropdownMenu(
      width: double.infinity,
      onSelected: (value) {
        setState(() {
          conditionValue = value!;
        });
      },
      initialSelection: conditionValue,
      dropdownMenuEntries:
          Condition.values.map((c) => DropdownMenuEntry<Condition>(value: c, label: c.getTitle(localization))).toList(),
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
      builder: (context) => const Center(
          child: CircularProgressIndicator(
        color: kPastelYellow,
      )),
    );

    await createNewItem(imagesController.images, imagesController.mainImage!.name, titleController.text, priceController.text, addressValue, descriptionController.text,
        conditionValue!, _selectedCategories);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> onEditItemButtonPressed() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing the dialog
      builder: (context) => const Center(
          child: CircularProgressIndicator(
        color: kPastelYellow,
      )),
    );

    imagesController.deletedImages.where((fileData) => fileData.fileRef != null).forEach((fileData) async {
      await deleteFile(fileData.fileRef!);
    });

    imagesController.images.where((fileData) => fileData.fileRef == null).forEach((fileData) async {
      await uploadFileData(getItemImageDirRef(item!.docRef), fileData);
    });

    await editItem(item!, imagesController.mainImage!.name, titleController.text, int.parse(priceController.text), addressValue,
        descriptionController.text, conditionValue!, _selectedCategories);
    Navigator.pop(context);
    Navigator.pop(context);
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
                SelectableImagesContainer(controller: imagesController),
                TextAndTextField(title: localization.title, controller: titleController),
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
                    style: kBlackTextStyle,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                widget.args.isEditMode
                    ? CustomButton(title: localization.edit, onPress: onEditItemButtonPressed)
                    : CustomButton(title: localization.addItem, onPress: onAddItemButtonPressed),
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
