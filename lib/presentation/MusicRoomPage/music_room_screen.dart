  import 'dart:typed_data';
  import 'package:flutter/material.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:just_audio/just_audio.dart';
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
    bool isLoading = false;

    @override
    void initState() {
      super.initState();

      FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .snapshots()
          .listen((doc) async {
            final data = doc.data();
            if (data != null && data['audioUrl'] != null) {
              String newUrl = data['audioUrl'];

              if (audioUrl != newUrl) {
                print("New audio URL from Firestore: $newUrl");

                try {
                  await _audioPlayer.setUrl(newUrl);
                  setState(() {
                    audioUrl = newUrl;
                    audioName = Uri.decodeFull(
                      newUrl.split('/').last.split('?').first,
                    );
                    isPlaying = false;
                  });
                } catch (e) {
                  print("Error setting audio URL: $e");
                }
              }
            }
          });
    }

    Future<void> pickAndUploadAudio(String roomCode) async {
      setState(() => isLoading = true);

      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          withData: true,
          allowedExtensions: ['mp3', 'm4a', 'mp4', 'wav'],
        );

        if (result != null && result.files.single.bytes != null) {
          Uint8List fileBytes = result.files.single.bytes!;
          String fileName = result.files.single.name;

          final supabase = Supabase.instance.client;
          final uploadPath = 'songs/$fileName';

          // Upload to Supabase
          await supabase.storage
              .from('music-files')
              .uploadBinary(
                uploadPath,
                fileBytes,
                fileOptions: const FileOptions(upsert: true),
              );

          final publicUrl = supabase.storage
              .from('music-files')
              .getPublicUrl(uploadPath);

          print("Uploaded to Supabase: $publicUrl");

          // Store in Firestore
          await FirebaseFirestore.instance
              .collection("rooms")
              .doc(roomCode)
              .update({"audioUrl": publicUrl});

          setState(() {
            audioName = fileName;
            audioUrl = publicUrl;
          });
        } else {
          print("No file selected or file bytes missing.");
        }
      } catch (e) {
        print("Error picking/uploading file: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      }

      setState(() => isLoading = false);
    }

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
                ElevatedButton.icon(
                  icon: Icon(Icons.upload_file),
                  label: Text("Pick & Upload Audio"),
                  onPressed: isLoading
                      ? null
                      : () => pickAndUploadAudio(widget.roomCode),
                ),

              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),

              SizedBox(height: 30),

              if (audioUrl != null)
                Column(
                  children: [
                    Text(
                      'Now Playing: ${audioName ?? "Unknown"}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 50,
                          onPressed: togglePlayPause,
                        ),
                      ],
                    ),
                    StreamBuilder<Duration>(
                      stream: _audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final totalDuration =
                            _audioPlayer.duration ?? Duration(seconds: 1);
                        return Slider(
                          min: 0,
                          max: totalDuration.inSeconds.toDouble(),
                          value: position.inSeconds
                              .clamp(0, totalDuration.inSeconds)
                              .toDouble(),
                          onChanged: (value) {
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        );
                      },
                    ),
                  ],
                )
              else
                Text(
                  'No audio uploaded yet.',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      );
    }
  }
