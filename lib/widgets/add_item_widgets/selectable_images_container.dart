import 'dart:io';

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../dialogs/select_image_dialog.dart';
import '../../dictionary.dart';
import '../../models/file_data.dart';
import '../../utils.dart';

class SelectableImagesContainer extends StatefulWidget {
  final SelectingImagesController controller;

  const SelectableImagesContainer({super.key, required this.controller});

  @override
  State<SelectableImagesContainer> createState() => _SelectableImagesContainerState();
}

class _SelectableImagesContainerState extends State<SelectableImagesContainer> {
  final kMaxImageCount = 8;

  void _onImagesPicked(List<File> images) async {
    setState(() {
      widget.controller.images.addAll(images
          .take(kMaxImageCount - widget.controller.images.length)
          .map((File file) => FileData.fromDataAndName(file.readAsBytesSync(), generateRandomString(4)))
          .toList());
      if (widget.controller.mainImage == null) {
        _updateMainImage();
      }
    });
  }

  Widget _getImageWidget(FileData fileData) {
    return Container(
      key: ValueKey(fileData.fullPath),
      width: 150,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.grey[200],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: fileData.exists
                ? Image.memory(
                    fileData.data,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.error),
          ),
          PositionedDirectional(
            top: 4,
            end: 4,
            child: GestureDetector(
              onTap: () {
                _onFileDeleted(fileData);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 4,
            start: 4,
            child: GestureDetector(
              onTap: () {
                _onFileSelectedAsMain(fileData);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (widget.controller.mainImage == fileData ? Colors.yellow : Colors.white).withOpacity(0.2),
                ),
                child: Icon(
                  widget.controller.mainImage == fileData ? Icons.star_rounded : Icons.star_border_rounded,
                  color: widget.controller.mainImage == fileData ? Colors.yellow : Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onFileDeleted(FileData fileData) {
    setState(() {
      widget.controller.deletedImages.add(fileData);
      widget.controller.images.remove(fileData);

      if (widget.controller.mainImage == fileData) {
        _updateMainImage();
      }
    });
  }

  void _onFileSelectedAsMain(FileData fileData) {
    setState(() {
      widget.controller.mainImage = fileData;
    });
  }

  void _updateMainImage() {
    widget.controller.mainImage = widget.controller.images.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    var localization = Dictionary.getLocalization(context);

    return GestureDetector(
      onTap: () {
        if (widget.controller.images.isEmpty) {
          SelectImageDialog(context).pickImages(_onImagesPicked);
        }
      },
      child: Container(
        height: 250,
        width: double.infinity,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kPastelYellowOpacity,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.controller.images.isNotEmpty
                ? Expanded(
                    child: Stack(
                      children: [
                        ReorderableListView(
                          padding: const EdgeInsetsDirectional.only(
                            start: 5,
                            end: 65,
                          ).resolve(Directionality.of(context)),
                          scrollDirection: Axis.horizontal,
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final FileData fileData = widget.controller.images.removeAt(oldIndex);
                              widget.controller.images.insert(newIndex, fileData);
                            });
                          },
                          children: widget.controller.images.map((fileData) => _getImageWidget(fileData)).toList(),
                        ),
                        PositionedDirectional(
                          top: 0,
                          bottom: 0,
                          end: 8,
                          child: GestureDetector(
                            onTap: () {
                              SelectImageDialog(context).pickImages(_onImagesPicked);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.7),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Text(localization.noImageSelected),
                      const SizedBox(height: 8),
                      const Icon(Icons.add_photo_alternate_outlined)
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class SelectingImagesController extends ValueNotifier<SelectingImagesValue> {
  SelectingImagesController([List<FileData>? images, FileData? mainFile])
      : super(SelectingImagesValue(images ?? [], [], mainFile));

  List<FileData> get images => value.images;

  List<FileData> get deletedImages => value.deletedImages;

  FileData? get mainImage => value.mainImage;

  set mainImage(FileData? file) => value.mainImage = file;
}

class SelectingImagesValue {
  List<FileData> images;
  List<FileData> deletedImages;
  FileData? mainImage;

  SelectingImagesValue(this.images, this.deletedImages, this.mainImage);
}
