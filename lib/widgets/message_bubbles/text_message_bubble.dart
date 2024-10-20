
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/services/cloud_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants.dart';
import '../../main.dart';
import '../../models/item.dart';
import '../../models/message.dart';
import '../../screens/item_screen.dart';

class TextMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool tail;

  const TextMessageBubble({super.key, required this.message, required this.isMe, required this.tail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        isMe ? const SizedBox(width: 4) : Container(),
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
    );
  }

}