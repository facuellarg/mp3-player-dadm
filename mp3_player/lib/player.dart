import 'dart:io';
import 'package:mp3_player/audio_player_manager.dart';
import 'package:mp3_player/nav_bar.dart';
import 'package:mp3_player/visualization.dart';
import 'songs.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'favorites_manager.dart';
import 'dart:async';

class MusicPlayerView extends StatefulWidget {
  final List<String> fileNames;
  final int currentSong;
  final Function(String)? onFavoriteChanged;

  const MusicPlayerView({
    Key? key,
    required this.fileNames,
    required this.currentSong,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<MusicPlayerView> createState() => _MusicPlayerViewState();
}

class _MusicPlayerViewState extends State<MusicPlayerView> {
  late AudioPlayer _audioPlayer;
  final AudioPlayerManager _playerManager = AudioPlayerManager.instance;
  bool _isPlaying = false;
  late int _currentIndex;
  bool _isFavorite = false;
  late StreamSubscription<PlayerState> _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentSong;
    _audioPlayer = _playerManager.player;
    _initAudioPlayer();
  }
Widget _buildControlButton({required IconData icon, required VoidCallback? onPressed, double size = 48}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(12),
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
    ),
  );
}
  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(widget.fileNames[_currentIndex])),
      );
      _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
        setState(() {
          _isPlaying = playerState.playing;
        });
      });
      _isFavorite = await FavoritesManager.isFavorite(widget.fileNames[_currentIndex]);
      setState(() {});
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _toggleFavorite() async {
    final songPath = widget.fileNames[_currentIndex];
    bool favoriteChanged = false;

    if (_isFavorite) {
      await FavoritesManager.removeFavorite(songPath);
      favoriteChanged = true;
    } else {
      await FavoritesManager.addFavorite(songPath);
      favoriteChanged = true;
    }

    // Si se proporciona onFavoriteChanged, llamamos a la función
    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!(songPath);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Devolver si hubo un cambio en el estado del favorito
    Navigator.pop(context, favoriteChanged);
  }

Future<void> _changeSong(int newIndex) async {
  if (newIndex < 0 || newIndex >= widget.fileNames.length) return;

  setState(() {
    _currentIndex = newIndex;
  });

  await _audioPlayer.setAudioSource(
    AudioSource.uri(Uri.parse(widget.fileNames[_currentIndex])),
  );

  _isFavorite = await FavoritesManager.isFavorite(widget.fileNames[_currentIndex]);
  setState(() {});
}

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
          title: const Text(
            'Listening',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: AudioVisualizer(audioPlayer: _audioPlayer),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      widget.fileNames[_currentIndex].split('/').last,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                   Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    _buildControlButton(
      icon: Icons.skip_previous,
      onPressed: _currentIndex > 0 ? () => _changeSong(_currentIndex - 1) : null,
      size: 36,
    ),
    _buildControlButton(
      icon: _isPlaying ? Icons.pause : Icons.play_arrow,
      onPressed: _togglePlayPause,
      size: 48,
    ),
    _buildControlButton(
      icon: Icons.skip_next,
      onPressed: _currentIndex < widget.fileNames.length - 1
          ? () => _changeSong(_currentIndex + 1)
          : null,
      size: 36,
    ),
  ],
)
,
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: MyNavigationBar(context),
      ),
    );
  }
}
