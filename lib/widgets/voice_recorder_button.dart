import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rent_app/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rent_app/services/cloud_services.dart';
import '../models/chat.dart';

class VoiceRecorderButton extends StatefulWidget {
  final Chat chat;
  final bool isUserIndex0;
  final VoidCallback? onMessageSent;

  const VoiceRecorderButton(
      {super.key,
      required this.chat,
      required this.isUserIndex0,
      this.onMessageSent});

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  late String recordingUrl;
  String? filePath;
  bool _micDenied = false;
  bool _recorderReady = false;
  late final Future<void> _recorderInit;

  Future<bool> _ensureMicPermission() async {
    PermissionStatus status = await Permission.microphone.status;

    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    // On iOS, restricted/limited/permanentlyDenied all mean no access
    final granted = status.isGranted;
    if (!granted) {
      setState(() {
        _micDenied = true;
      });
    }
    return granted;
  }

  @override
  void initState() {
    super.initState();
    _recorderInit = _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await _setFilePath();
    if (mounted) {
      setState(() {
        _recorderReady = true;
      });
    }
  }

  Future<void> _setFilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    await tempDir.create(recursive: true);
    String path =
        '${tempDir.path}/voice_record_${DateTime.now().millisecondsSinceEpoch}.aac';
    setState(() {
      filePath = path;
    });
  }

  Future<void> startRecording() async {
    await _recorderInit;
    if (!_recorderReady) return;

    final granted = await _ensureMicPermission();
    if (!granted) return;

    if (isRecording) return;

    if (filePath != null) {
      await _recorder.startRecorder(toFile: filePath);
      setState(() {
        isRecording = true;
        _micDenied = false;
      });
    }
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();

    setState(() {
      isRecording = false;
    });

    if (filePath == null) return;

    final recordedFile = File(filePath!);
    if (!await recordedFile.exists()) {
      return;
    }

    await sendRecordMessage(widget.chat.docRef, widget.isUserIndex0, recordedFile);
    widget.onMessageSent?.call();
    // prepare a fresh path for the next recording
    await _setFilePath();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: startRecording,
      onLongPressUp: stopRecording,
      child: IconButton(
        onPressed: null,
        icon: Icon(
          isRecording ? Icons.mic : Icons.mic_none,
          color: _micDenied
              ? Colors.red
              : isRecording
                  ? Colors.red
                  : kBlackColor,
        ),
        tooltip: _micDenied ? 'Microphone permission needed' : null,
      ),
    );
  }
}
