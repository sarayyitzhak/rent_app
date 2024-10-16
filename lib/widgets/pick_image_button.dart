import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_app/constants.dart';

class PickImageButton extends StatefulWidget {
  final Function(File?) onImagePicked;
  IconData icon;
  PickImageButton({super.key, required this.onImagePicked, this.icon = Icons.add_a_photo_outlined});
  @override
  State<PickImageButton> createState() => _PickImageButtonState();

}
class _PickImageButtonState extends State<PickImageButton> {
  File? image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 15);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      widget.onImagePicked(image);
    }
  }

  Column pickImageMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
            child: Text(
              'Pick an image from:',
              style: TextStyle(color: Colors.grey),
            )),
        const Divider(),
        TextButton(
            child: const Text(
              'Camera',
              style: kBlackHeaderTextStyle,
            ),
            onPressed: () {
              _pickImage(ImageSource.camera);
              Navigator.pop(context);
            }),
        const Divider(),
        TextButton(
            child: const Text(
              'Gallery',
              style: kBlackHeaderTextStyle,
            ),
            onPressed: () {
              _pickImage(ImageSource.gallery);
              Navigator.pop(context);
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(widget.icon),
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
            ),
        );
      },
    );
  }
}

