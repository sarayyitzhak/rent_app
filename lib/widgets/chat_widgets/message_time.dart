import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/message.dart';

class MessageTime extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageTime({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            color: Colors.grey[isMe ? 300 : 700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
