
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants.dart';
import '../../main.dart';
import '../../models/item.dart';
import '../../models/message.dart';
import '../../screens/item_screen.dart';
import '../custom_app_bar.dart';

class ImageMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool tail;

  const ImageMessageBubble({super.key, required this.message, required this.isMe, required this.tail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return _DetailScreen(
                imageUrl: message.fileRef!,
              );
            }));
          },
          child: CachedNetworkImage(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.9,
            imageUrl: message.fileRef!,
            placeholder: (context, url) => Container(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3, vertical: MediaQuery.of(context).size.width * 0.3),
                child: const CircularProgressIndicator(color: kPastelYellow,)
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            isMe ? Icon(
                message.read ? Icons.done_all : Icons.done,
                color: message.read ? Colors.cyan[300] : Colors.grey[300],
                size: 18
            ) : Container(),
            const SizedBox(width: 4),
            Text(
              message.sentAtAsString(),
              style: TextStyle(
                color: Colors.grey[isMe ? 300 : 700]!,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

}

/// detail screen of the image, display when tap on the image bubble
class _DetailScreen extends StatefulWidget {
  final String imageUrl;

  _DetailScreen({super.key, required this.imageUrl});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

/// created using the Hero Widget
class _DetailScreenState extends State<_DetailScreen> {
  final TransformationController _transformationController = TransformationController();
  bool _zoomedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        isBackButton: true,
      ),
      body: Center(
        child: GestureDetector(
            onDoubleTapDown: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: true, // Enable panning
              maxScale: 3,   // Maximum zoom in scale
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
              ),
            )
        ),
      ),
    );
  }

  // Toggle zoom in and zoom out on double-tap
  void _handleDoubleTap(TapDownDetails details) {
    setState(() {
      if (_zoomedIn) {
        _transformationController.value = Matrix4.identity(); // Zoom out
      } else {

        // Get the position where the user tapped
        final position = details.localPosition;

        // Create a zoom matrix focused on the tap position
        final x = -position.dx * 2 + MediaQuery.of(context).size.width / 2;
        final y = -position.dy * 2 + MediaQuery.of(context).size.height / 2;
        _transformationController.value = Matrix4.identity()
          ..translate(x, y)
          ..scale(2.0); // Zoom in by 2x
      }
      _zoomedIn = !_zoomedIn; // Toggle zoom state
    });
  }
}