import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rent_app/models/file_data.dart';
import 'package:rent_app/utils.dart';
import '../widgets/custom_app_bar.dart';

class ImageViewGalleryScreen extends StatefulWidget {
  static String id = 'initial_screen.dart';

  final ImageViewGalleryScreenArguments args;

  const ImageViewGalleryScreen(this.args, {super.key});

  @override
  State<ImageViewGalleryScreen> createState() => _ImageViewGalleryScreenState();
}

class _ImageViewGalleryScreenState extends State<ImageViewGalleryScreen> {
  final PageController _pageController = PageController();

  String title = '';
  List<Uint8List> _images = [];

  Future<void> _fetchImagesData() async {
    List<Uint8List> images = [];
    for (Reference imageRef in widget.args.imageRefs) {
      FileData fileData = await getFileData(imageRef);
      images.add(fileData.data);
    }

    setState(() {
      _images = images;
      _updateTitle(widget.args.index);
    });

    _pageController.jumpToPage(widget.args.index);
  }

  void _updateTitle(int index) {
    if (_images.length > 1) {
      AppLocalizations localization = AppLocalizations.of(context)!;
      title = localization.outOf(index + 1, _images.length);
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchImagesData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        isBackButton: true,
        backIcon: Icons.close_rounded,
      ),
      body: PhotoViewGallery.builder(
        itemCount: _images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: MemoryImage(_images[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.white),
        onPageChanged: (int index) {
          setState(() {
            _updateTitle(index);
          });
        },
        pageController: _pageController,
      ),
    );
  }
}

class ImageViewGalleryScreenArguments {
  final List<Reference> imageRefs;
  final int index;

  ImageViewGalleryScreenArguments(this.imageRefs, [this.index = 0]);
}
