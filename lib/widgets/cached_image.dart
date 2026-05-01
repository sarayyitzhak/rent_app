import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:rent_app/utils.dart';

class CachedImage extends StatefulWidget {
  final Reference? imageRef;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context)? placeholder;
  final Widget Function(BuildContext context)? errorWidget;
  final Widget Function(BuildContext context, ImageProvider)? imageBuilder;
  final BorderRadiusGeometry? borderRadius;
  final IconData errorIcon;

  const CachedImage(
      {super.key,
      this.imageRef,
      this.width,
      this.height,
      this.placeholder,
      this.errorWidget,
      this.imageBuilder,
      this.borderRadius,
      this.errorIcon = Icons.error});

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  Widget? _image;

  @override
  void didUpdateWidget(covariant CachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPath = oldWidget.imageRef?.fullPath;
    final newPath = widget.imageRef?.fullPath;
    if (oldPath != newPath) {
      _image = null;
    }
  }

  Widget _getPlaceholder(BuildContext context) {
    return widget.placeholder != null
        ? widget.placeholder!(context)
        : Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              color: Colors.grey[200],
            ),
          );
  }

  Widget _getImageBuilder(BuildContext context, ImageProvider imageProvider) {
    return widget.imageBuilder != null
        ? widget.imageBuilder!(context, imageProvider)
        : Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          );
  }

  Widget _getErrorWidget(BuildContext context) {
    return widget.errorWidget != null
        ? widget.errorWidget!(context)
        : Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              color: Colors.grey[200],
            ),
            child: Icon(widget.errorIcon),
          );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _image ?? (widget.imageRef == null
              ? _getPlaceholder(context)
              : FutureBuilder(
                  future: getFileData(widget.imageRef!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _getPlaceholder(context);
                    } else if (snapshot.hasData && snapshot.data!.exists) {
                      _image = _getImageBuilder(context, MemoryImage(snapshot.data!.data));
                      return _image!;
                    } else {
                      return _getErrorWidget(context);
                    }
                  },
                )),
    );
  }
}
