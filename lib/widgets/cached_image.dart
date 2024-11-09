import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import 'package:rent_app/services/cloud_services.dart';

class CachedImage extends StatelessWidget {
  final Reference? imageRef;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context)? placeholder;
  final Widget Function(BuildContext context)? errorWidget;
  final Widget Function(BuildContext context, ImageProvider)? imageBuilder;
  final BorderRadiusGeometry? borderRadius;

  const CachedImage(
      {super.key,
      this.imageRef,
      this.width,
      this.height,
      this.placeholder,
      this.errorWidget,
      this.imageBuilder,
      this.borderRadius});

  Future<Uint8List?> _fetchImageData() async {
    if (imageRef == null) {
      return null;
    }
    try {
      String path = imageRef!.fullPath;

      FileInfo? cachedFile = await DefaultCacheManager().getFileFromMemory(path);

      if (cachedFile != null) {
        return await cachedFile.file.readAsBytes();
      } else {
        cachedFile = await DefaultCacheManager().getFileFromCache(path);

        if (cachedFile != null) {
          return await cachedFile.file.readAsBytes();
        } else {
          return await readFile(imageRef!);
        }
      }
    } catch (e) {
      return null;
    }
  }

  Widget _getPlaceholder(BuildContext context) {
    return placeholder != null
        ? placeholder!(context)
        : Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: Colors.grey[200],
            ),
          );
  }

  Widget _getImageBuilder(BuildContext context, ImageProvider imageProvider) {
    return imageBuilder != null
        ? imageBuilder!(context, imageProvider)
        : Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          );
  }

  Widget _getErrorWidget(BuildContext context) {
    return errorWidget != null ? errorWidget!(context) : const Icon(Icons.error);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: imageRef == null
          ? _getPlaceholder(context)
          : FutureBuilder(
              future: _fetchImageData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _getPlaceholder(context);
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _getImageBuilder(context, MemoryImage(snapshot.data!));
                } else {
                  return _getErrorWidget(context);
                }
              },
            ),
    );
  }
}
