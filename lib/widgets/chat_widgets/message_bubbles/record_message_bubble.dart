import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:rent_app/models/message.dart';
import 'package:rent_app/services/cloud_services.dart';

import '../../../constants.dart';
import '../../../models/chat.dart';
import '../message_time.dart';

class RecordMessageBubble extends StatefulWidget {
  final Chat chat;
  final Message message;
  final bool isMe;
  final bool tail;

  const RecordMessageBubble({super.key, required this.chat, required this.message, required this.isMe, required this.tail});

  @override
  State<RecordMessageBubble> createState() => _RecordMessageBubbleState();
}

class _RecordMessageBubbleState extends State<RecordMessageBubble> {
  final player = AudioPlayer();
  double _duration = 0;
  double _position = 0;
  bool isPlaying = false;
  bool isPauseAuto = false;

  Future<Uint8List?> _fetchSoundData() async {
    try {
      Reference soundRef = getMessageFileRef(widget.message.cloudKey!, 'aac');

      String path = soundRef.fullPath;

      FileInfo? cachedFile = await DefaultCacheManager().getFileFromMemory(path);

      if (cachedFile != null) {
        return await cachedFile.file.readAsBytes();
      } else {
        cachedFile = await DefaultCacheManager().getFileFromCache(path);

        if (cachedFile != null) {
          return await cachedFile.file.readAsBytes();
        } else {
          return await readFile(soundRef, 'aac');
        }
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _playPauseAudio() async {
    if (isPlaying) {
      await player.pause();
    } else {
      Uint8List? data = await _fetchSoundData();
      if (data != null) {
        await player.play(BytesSource(data), position: Duration(seconds: _position.toInt()));
      }
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  String _formatDuration(double seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = (seconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _initPlayer() async {
    Uint8List? data = await _fetchSoundData();
    if (data != null) {
      player.setSourceBytes(data);
    }
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
    player.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration.inSeconds.toDouble();
      });
    });
    player.onPositionChanged.listen((position) {
      setState(() {
        _position = position.inSeconds.toDouble();
      });
    });
    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        _position = 0; // Reset position to the start
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            _playPauseAudio();
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: kWhiteColor,
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 26,
              color: kBlackColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                  child: Slider(
                    value: _position,
                    min: 0.0,
                    max: _duration,
                    label: _formatDuration(_position),
                    onChangeStart: (double newValue) {
                      if (isPlaying) {
                        isPauseAuto = true;
                        _playPauseAudio();
                      }
                    },
                    onChanged: (double newValue) {
                      setState(() {
                        _position = newValue;
                      });
                    },
                    onChangeEnd: (double newValue) {
                      if (isPauseAuto) {
                        _playPauseAudio();
                        isPauseAuto = false;
                      }
                    },
                    thumbColor: Colors.black,
                    activeColor: Colors.grey[700],
                    inactiveColor: Colors.grey,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _formatDuration(_position > 0 ? _position : _duration),
                        style: TextStyle(
                          color: Colors.grey[widget.isMe ? 300 : 700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    MessageTime(chat: widget.chat, message: widget.message, isMe: widget.isMe)
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
