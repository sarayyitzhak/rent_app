import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rent_app/models/message.dart';



class RecordMessageBubble extends StatefulWidget {
  Message message;
  final bool isMe;
  bool tail;

  RecordMessageBubble({super.key, required this.message, required this.isMe, required this.tail});

  @override
  State<RecordMessageBubble> createState() => _RecordMessageBubbleState();
}

class _RecordMessageBubbleState extends State<RecordMessageBubble> {
  final player = AudioPlayer();
  Duration? _duration;
  Duration _position = Duration.zero;
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  Future<void> _playPauseAudio() async {
    if (isPlaying) {
      await player.pause();
      setState(() {
        isPlaying = false;
        isPause = true;
      });
    } else {
      await player.play(UrlSource(widget.message.fileRef!));
      setState(() {
        isPlaying = true;
        isPause = false;
      });
    }
  }

  void _changeSeek(double value) async {
    await player.seek(Duration(seconds: value.toInt()));
  }

  @override
  void initState() {
    super.initState();
    if (widget.message.fileRef != null && widget.message.fileRef!.isNotEmpty) {
      player.setSourceUrl(widget.message.fileRef!);
    }
    player.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    player.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        _position = Duration.zero; // Reset position to the start
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
    return BubbleNormalAudio(
      color: widget.isMe ? Colors.blue : Colors.grey[300]!,
      isSender: widget.isMe,
      duration: _duration?.inSeconds.toDouble(),
      position: _position?.inSeconds.toDouble(),
      isPlaying: isPlaying,
      isLoading: isLoading,
      isPause: isPause,
      tail: widget.tail,
      sent: widget.isMe ? !widget.message.read : false,
      seen: widget.isMe ? widget.message.read : false,
      onSeekChanged:  (value) => _changeSeek(value),
      onPlayPauseButtonClick: () => _playPauseAudio(),
    );
  }
}
