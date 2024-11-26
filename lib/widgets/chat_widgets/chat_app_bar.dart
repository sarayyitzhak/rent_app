import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rent_app/dictionary.dart';
import 'package:rent_app/utils.dart';

import '../../models/user.dart';
import '../../services/cloud_services.dart';
import '../cached_image.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String participantUid;

  const ChatAppBar({super.key, required this.participantUid});

  @override
  State<ChatAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<ChatAppBar> {
  UserDetails? _participantUser;
  DateTime? _participantLastSeenTime;
  bool? _participantOnline;

  bool? _isParticipantOnline;

  Timer? _lastSeenTimeTimer;
  StreamSubscription? _userSubscription;

  Future<void> _fetchParticipantUser() async {
    _userSubscription = getUserByIDStream(widget.participantUid).listen((UserDetails participantUser) {
      if (_participantUser == null) {
        setState(() {
          _participantUser = participantUser;
        });
      }

      if (_participantLastSeenTime != participantUser.lastSeenTime || _participantOnline != participantUser.online) {
        _participantLastSeenTime = participantUser.lastSeenTime;
        _participantOnline = participantUser.online;

        if (_participantOnline!) {
          Duration difference = _participantLastSeenTime!.add(const Duration(minutes: 2)).difference(DateTime.now());
          setState(() {
            _isParticipantOnline = !difference.isNegative;
          });
          if (_isParticipantOnline!) {
            _lastSeenTimeTimer?.cancel();

            _lastSeenTimeTimer = Timer(difference, () {
              setState(() {
                _isParticipantOnline = false;
              });
            });
          }
        } else {
          setState(() {
            _isParticipantOnline = false;
          });
        }
      }
    });
  }

  String _getParticipantOnline(BuildContext context) {
    if (_isParticipantOnline != null) {
      if (_isParticipantOnline!) {
        return Dictionary.getLocalization(context).online;
      } else {
        DateTime now = DateTime.now();
        Duration difference = now.difference(_participantLastSeenTime!);
        if (difference.isNegative) {
          return '';
        } else {
          String hourMinuteFormat = getHourMinuteFormat(_participantLastSeenTime!);
          if (difference.inDays == 0) {
            return Dictionary.getLocalization(context).lastSeenTodayAtTime(hourMinuteFormat);
          } else if (difference.inDays == 1) {
            return Dictionary.getLocalization(context).lastSeenYesterdayAtTime(hourMinuteFormat);
          } else {
            String dateFormat = dateToString(_participantLastSeenTime!);
            return Dictionary.getLocalization(context).lastSeenOnDateAtTime(dateFormat, hourMinuteFormat);
          }
        }
      }
    } else {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchParticipantUser();
  }

  @override
  void dispose() {
    _lastSeenTimeTimer?.cancel();
    _userSubscription?.cancel();

    super.dispose();
  }

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          CachedImage(
            width: 50,
            height: 50,
            imageRef:
                _participantUser != null ? getUserImageRef(_participantUser!.docRef, _participantUser!.photoID) : null,
            borderRadius: BorderRadius.circular(100),
            errorIcon: Icons.person,
          ),
          const SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_participantUser?.name ?? ''),
              Text(
                _getParticipantOnline(context),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
      automaticallyImplyLeading: true,
    );
  }
}
