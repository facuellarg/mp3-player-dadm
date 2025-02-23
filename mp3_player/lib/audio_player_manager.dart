import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  AudioPlayer? _audioPlayer;

  // Private constructor
  AudioPlayerManager._internal();

  // Singleton instance getter
  static AudioPlayerManager get instance => _instance;

  AudioPlayer get player {
    _audioPlayer ??= AudioPlayer();
    return _audioPlayer!;
  }

  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
  }

  Future<void> setNewSource(String source) async {
    try {
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(source),
        ),
      );
    } catch (e) {
      debugPrint("Error setting audio source: $e");
    }
  }

  Future<void> stopAndDispose() async {
    try {
      await _audioPlayer?.stop();
      _audioPlayer?.dispose();
      _audioPlayer = null;
    } catch (e) {
      debugPrint("Error disposing audio player: $e");
    }
  }
}
