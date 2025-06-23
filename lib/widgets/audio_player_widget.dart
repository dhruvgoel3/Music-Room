import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String roomCode;
  final String userId;
  final bool isCreator;

  const AudioPlayerWidget({
    super.key,
    required this.roomCode,
    required this.userId,
    required this.isCreator,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isBuffering = true;

  @override
  void initState() {
    super.initState();
    _listenToRoomPlayback();
  }

  void _listenToRoomPlayback() {
    FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.roomCode)
        .snapshots()
        .listen((doc) async {
          if (!doc.exists) return;
          final data = doc.data()!;
          final audioUrl = data['audioUrl'];
          final playback = data['playback'];

          if (_player.audioSource == null && audioUrl != "") {
            await _player.setUrl(audioUrl);
            setState(() => _isBuffering = false);
          }

          if (playback != null && playback['lastUpdatedBy'] != widget.userId) {
            bool isPlaying = playback['isPlaying'];
            int position = playback['position'];

            await _player.seek(Duration(milliseconds: position));
            isPlaying ? _player.play() : _player.pause();
          }
        });
  }

  void _updatePlayback(bool isPlaying) {
    FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).update({
      "playback": {
        "isPlaying": isPlaying,
        "position": _player.position.inMilliseconds,
        "lastUpdatedBy": widget.userId,
      },
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isBuffering
        ? CircularProgressIndicator()
        : Column(
            children: [
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return Slider(
                    min: 0,
                    max: _player.duration?.inMilliseconds.toDouble() ?? 1,
                    value: position.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      _player.seek(Duration(milliseconds: value.toInt()));
                      _updatePlayback(_player.playing);
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _player.playing ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (_player.playing) {
                        _player.pause();
                        _updatePlayback(false);
                      } else {
                        _player.play();
                        _updatePlayback(true);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: () {
                      _player.stop();
                      _updatePlayback(false);
                    },
                  ),
                ],
              ),
            ],
          );
  }
}
