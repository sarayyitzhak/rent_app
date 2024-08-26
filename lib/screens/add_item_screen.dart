import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_app/constants.dart';
import 'package:rent_app/models/category.dart';
import 'package:rent_app/screens/user_items_screen.dart';
import 'package:rent_app/services/address_services.dart';
import 'package:rent_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/widgets/custom_button.dart';
import 'package:rent_app/widgets/text_and_text_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

import '../main.dart';
import '../models/item.dart';

class AddItemScreen extends StatefulWidget {
  static String id = 'add_item_screen';
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final storageRef = FirebaseStorage.instance.ref();
  File? _image;
  var userUid = 'O3mgqVZxaVUwkquZSW4Yg0zfeJM2'; // TODO: delete



  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late String conditionValue;
  late AddressInfo addressValue =
      AddressInfo(latitude: 0, longitude: 0, addressData: {'city': '', 'road': ''});
  var _selectedCategories = [];
  late List<dynamic> categories;
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
  }

  Future<void> mapDialogBuilder(BuildContext context, var localization) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please choose location'),
          insetPadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(8),
          content: Container(
            height: 600,
            width: MediaQuery.of(context).size.width - 40,
            // width: double.infinity,
            child: FlutterLocationPicker(
                searchBarHintText: localization.searchLocation,
                urlTemplate: kMapUrl,
                mapLanguage: localization.language,
                initPosition: LatLong(23, 89),
                selectLocationButtonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                ),
                selectedLocationButtonTextStyle: const TextStyle(fontSize: 18),
                selectLocationButtonText: 'Set Location',
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
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Set'),
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Column pickImageMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
            child: Text(
          'Pick an image from:',
          style: TextStyle(color: Colors.grey),
        )),
        Divider(),
        TextButton(
            child: Text(
              'Camera',
              style: kButtonTextStyle,
            ),
            onPressed: () {
              _pickImage(ImageSource.camera);
              Navigator.pop(context);
            }),
        Divider(),
        TextButton(
            child: Text(
              'Gallery',
              style: kButtonTextStyle,
            ),
            onPressed: () {
              _pickImage(ImageSource.gallery);
              Navigator.pop(context);
            }),
      ],
    );
  }

  IconButton addImageButton() {
    return IconButton(
      icon: Icon(Icons.add_a_photo_outlined),
      onPressed: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: pickImageMenu(),
                    ),
                  ),
                ));
      },
    );
  }

  Container buildImageContainer() {
    return Container(
        height: 200,
        width: double.infinity,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kLightYellow,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(
                    _image!,
                    width: 150, // specify desired width
                    height: 150, // specify desired height
                    fit: BoxFit.fill,
                  )
                : Text('No image selected.'),
            addImageButton(),
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
                buildImageContainer(),
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
                    color: kLightYellow,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  items: ItemCategory.values
                      .map((e) => MultiSelectItem(e, e.title))
                      .toList(),
                  initialChildSize: 0.6,
                  initialValue: _selectedCategories,
                  onConfirm: (values) {
                    _selectedCategories = values;
                  },
                ),
                SizedBox(
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
                    color: kLightYellow,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownMenu(
                      width: double.infinity,
                      onSelected: (String? value) {
                        setState(() {
                          conditionValue = value!;
                        });
                      },
                      dropdownMenuEntries: const [
                        DropdownMenuEntry<String>(value: 'new', label: 'new'),
                        DropdownMenuEntry<String>(
                            value: 'used as new', label: 'used as new'),
                        DropdownMenuEntry<String>(
                            value: 'used in good shape',
                            label: 'used in good shape'),
                        DropdownMenuEntry<String>(
                            value: 'used in medium shape',
                            label: 'used in medium shape'),
                      ],
                      inputDecorationTheme: InputDecorationTheme(
                        fillColor: kLightYellow,
                        hoverColor: kLightYellow,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                TextAndTextField(
                  title: localization.description,
                  controller: descriptionController,
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
                  child: Text(
                    addressValue.addressDataToString(),
                      // '${addressValue.addressData['city']}${addressValue.addressData['road'] != null ? ',  ${addressValue.addressData['road']}' : ''}',
                    style: kBlackTextStyle,),
                  style: kAddressButtonStyle,
                ),

                SizedBox(
                  height: 15,
                ),

                CustomButton(title: localization.addItem, onPress: () async {
                  Item newItem = Item(userUid: userUid.toString(), imageRef: '', title: titleController.text, price: double.parse(priceController.text), location: addressValue, description: descriptionController.text, condition: conditionValue, categories: _selectedCategories);
                  var itemDoc = _firestore.collection('items').doc();
                  final itemRef = storageRef.child(itemDoc.id);
                  UploadTask uploadTask = itemRef.putFile(_image!);
                  TaskSnapshot taskSnapshot = await uploadTask;
                  var imageDownloadUrl = await taskSnapshot.ref.getDownloadURL();

                  newItem.imageRef = imageDownloadUrl;
                  itemDoc.set(newItem.itemAsMap());
                  
                  var userDoc = _firestore.collection('users').doc(userUid);
                  var userGet = await userDoc.get();
                  if (userGet.exists) {
                    Map<String, dynamic> userData = userGet.data()!;
                    var userItems = userData['userItems'];
                    if(userItems == null){
                      userDoc.update({'userItems': []});
                    }
                    userDoc.update({'userItems': FieldValue.arrayUnion([itemDoc.id])});
                  } else {
                    //problem
                  }
                  Navigator.popAndPushNamed(context, UserItemsScreen.id);
                  // Navigator.pop(context);
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
