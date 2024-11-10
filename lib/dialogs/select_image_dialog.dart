import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_app/constants.dart';

class SelectImageDialog {
  final BuildContext _context;
  Function(File)? _onImagePicked;
  Function(List<File>)? _onImagesPicked;

  SelectImageDialog(this._context);

  void _showDialog() {
    showModalBottomSheet(
      context: _context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _pickImageMenu(),
          ),
        ),
      ),
    );
  }

  Column _pickImageMenu() {
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
              _pickImages(ImageSource.camera);
              Navigator.pop(_context);
            }),
        const Divider(),
        TextButton(
            child: const Text(
              'Gallery',
              style: kBlackHeaderTextStyle,
            ),
            onPressed: () {
              _pickImages(ImageSource.gallery);
              Navigator.pop(_context);
            }),
      ],
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    if (source == ImageSource.camera) {
      XFile? pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 15);
      if (pickedFile != null) {
        if (_onImagePicked != null) {
          _onImagePicked!(File(pickedFile.path));
        } else if (_onImagesPicked != null) {
          _onImagesPicked!([File(pickedFile.path)]);
        }
      }
    } else if (source == ImageSource.gallery) {
      if (_onImagePicked != null) {
        XFile? pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 15);
        if (pickedFile != null) {
          _onImagePicked!(File(pickedFile.path));
        }
      } else if (_onImagesPicked != null) {
        List<XFile> pickedFiles = await ImagePicker().pickMultiImage(imageQuality: 15);
        _onImagesPicked!(pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
      }
    }
  }

  void pickImage(Function(File) onImagePicked) {
    _onImagePicked = onImagePicked;
    _showDialog();
  }

  void pickImages(Function(List<File>) onImagesPicked) {
    _onImagesPicked = onImagesPicked;
    _showDialog();
  }
}
