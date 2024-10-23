import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rent_app/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rent_app/models/message.dart';
import 'package:rent_app/models/message_type.dart';
import '../models/chat.dart';

class VoiceRecorderButton extends StatefulWidget {
  Chat chat;
  int userIdx;
  VoiceRecorderButton({required this.chat, required this.userIdx, super.key});

  @override
  _VoiceRecorderButtonState createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  final storageRef = FirebaseStorage.instance.ref();
  late String recordingUrl;
  String? filePath;

  Future<void> checkPermissions() async {
    if(await Permission.microphone.isDenied){
      Permission.microphone.request();
    }
    if(await Permission.microphone.isDenied){
      throw 'don\'t have permissions';
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermissions();
    _recorder.openRecorder();
    _setFilePath();
  }

  Future<void> _setFilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/voice_record.aac';
    setState(() {
      filePath = path;
    });
  }

  Future<void> startRecording() async {
    if (filePath != null) {
      await _recorder.startRecorder(toFile: filePath);
      setState(() {
        isRecording = true;
      });
    }
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });
    uploadVoiceRecording(filePath!);
  }

  Future<void> uploadVoiceRecording(String filePath) async {
    File file = File(filePath);
    final recordingRef = storageRef.child('voice_record_${DateTime.now().millisecondsSinceEpoch}.aac');
    UploadTask uploadTask = recordingRef.putFile(file!);
    TaskSnapshot taskSnapshot = await uploadTask;
    recordingUrl = await taskSnapshot.ref.getDownloadURL();
    DateTime sentAt = Timestamp.now().toDate();
    Message message = Message(sender: widget.userIdx, text: 'הקלטה קולית', sentAt: sentAt, fileRef: recordingUrl, type: MessageType.VOICE_RECORD);
    widget.chat.docRef.collection('messages').add(message.toMap());
    widget.chat.docRef.update({'lastMessageSentAt': sentAt});
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
      child: Icon(
        isRecording ? Icons.mic : Icons.mic_none,
        // size: 40,
        color: isRecording ? Colors.red : kBlackColor,
      ),
    );
  }
}
