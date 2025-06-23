import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_room/presentation/MusicRoomPage/pick_audio_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusicRoomScreen extends StatefulWidget {
  final String roomCode;
  final String userId;
  final bool isCreator;

  const MusicRoomScreen({
    super.key,
    required this.roomCode,
    required this.userId,
    required this.isCreator,
  });

  @override
  State<MusicRoomScreen> createState() => _MusicRoomScreenState();
}

class _MusicRoomScreenState extends State<MusicRoomScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? audioName;
  bool isPlaying = false;
  String? audioUrl;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomCode)
        .snapshots()
        .listen((doc) async {
          String? newUrl = doc.data()?['audioUrl'];
          if (newUrl != null && newUrl != audioUrl) {
            await _audioPlayer.setUrl(newUrl);
            setState(() {
              audioUrl = newUrl;
              audioName = newUrl.split('/').last;
            });
          }
        });
  }

  // Future<void> pickAndUploadAudio(String roomCode) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.audio,
  //   );
  //
  //   if (result != null && result.files.single.bytes != null) {
  //     Uint8List fileBytes = result.files.single.bytes!;
  //     String fileName = result.files.single.name;
  //
  //     final supabase = Supabase.instance.client;
  //
  //     // Upload audio to Supabase
  //     final uploadPath = 'songs/$fileName';
  //
  //     await supabase.storage
  //         .from('music-files') // Your bucket name
  //         .uploadBinary(
  //           uploadPath,
  //           fileBytes,
  //           fileOptions: const FileOptions(upsert: true),
  //         );
  //
  //     // Get public URL
  //     final publicUrl = supabase.storage
  //         .from('music-files')
  //         .getPublicUrl(uploadPath);
  //
  //     print("Uploaded to: $publicUrl");
  //
  //     // Save to Firestore
  //     await FirebaseFirestore.instance
  //         .collection("rooms")
  //         .doc(widget.roomCode)
  //         .update({"audioUrl": publicUrl});
  //
  //     setState(() {
  //       audioName = fileName;
  //       audioUrl = publicUrl;
  //     });
  //   }
  // }

  void togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
      setState(() => isPlaying = false);
    } else {
      _audioPlayer.play();
      setState(() => isPlaying = true);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room: ${widget.roomCode}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (widget.isCreator)
              ElevatedButton(
                onPressed: () => pickAndUploadAudio(widget.roomCode),
                child: Text("Pick & Upload Audio"),
              ),

            SizedBox(height: 20),
            if (audioName != null)
              Column(
                children: [
                  Text('Now Playing: $audioName'),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 50,
                    onPressed: togglePlayPause,
                  ),
                  StreamBuilder<Duration>(
                    stream: _audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      return Slider(
                        min: 0,
                        max: _audioPlayer.duration?.inSeconds.toDouble() ?? 1,
                        value: snapshot.data?.inSeconds.toDouble() ?? 0,
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(seconds: value.toInt()));
                        },
                      );
                    },
                  ),
                ],
              )
            else
              Text('No audio uploaded yet.'),
          ],
        ),
      ),
    );
  }
}
