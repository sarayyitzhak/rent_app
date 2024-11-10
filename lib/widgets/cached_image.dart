import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:rent_app/utils.dart';

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
              future: getFileData(imageRef!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _getPlaceholder(context);
                } else if (snapshot.hasData && snapshot.data!.exists) {
                  return _getImageBuilder(context, MemoryImage(snapshot.data!.data));
                } else {
                  return _getErrorWidget(context);
                }
              },
            ),
    );
  }
}
