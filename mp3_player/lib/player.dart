import 'dart:io';
import 'package:mp3_player/favorites.dart';
import 'package:mp3_player/nav_bar.dart';
import 'package:mp3_player/visualization.dart';

import 'songs.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class MusicPlayerView extends StatefulWidget {
  final List<String> fileNames;
  final int currentSong;

  const MusicPlayerView(FileSystemEntity file,
      {Key? key, required this.fileNames, required this.currentSong})
      : super(key: key);

  @override
  State<MusicPlayerView> createState() => _MusicPlayerViewState();
}

class _MusicPlayerViewState extends State<MusicPlayerView> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentSong;
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.fileNames[_currentIndex]),
        ),
      );

      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.playing != _isPlaying) {
          setState(() {
            _isPlaying = playerState.playing;
          });
        }
      });

      // Add listener for when song completes
      _audioPlayer.positionStream.listen((position) {
        if (position >= (_audioPlayer.duration ?? Duration.zero)) {
          _playNextSong();
        }
      });
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  Future<void> _playNextSong() async {
    if (_currentIndex < widget.fileNames.length - 1) {
      setState(() {
        _currentIndex++;
      });
      await _loadAndPlaySong();
    }
  }

  Future<void> _playPreviousSong() async {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      await _loadAndPlaySong();
    }
  }

  Future<void> _loadAndPlaySong() async {
    try {
      await _audioPlayer.dispose();
      // Create a new instance of AudioPlayer
      setState(() {
        _audioPlayer = AudioPlayer();
      });

      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.fileNames[_currentIndex]),
        ),
      );

      // Reattach the player state listener
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.playing != _isPlaying) {
          setState(() {
            _isPlaying = playerState.playing;
          });
        }
      });

      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error changing song: $e");
    }
  }

  Stream<Duration> get _positionStream =>
      Rx.combineLatest2<Duration, Duration?, Duration>(
        _audioPlayer.positionStream,
        _audioPlayer.durationStream,
        (position, duration) => position,
      );

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
                    StreamBuilder<IcyMetadata?>(
                      stream: _audioPlayer.icyMetadataStream,
                      builder: (context, snapshot) {
                        final artist = snapshot.data?.info?.title
                                ?.split(' - ')
                                .lastOrNull ??
                            '';
                        return artist.isNotEmpty
                            ? Text(
                                artist,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    StreamBuilder<Duration>(
                      stream: _positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = _audioPlayer.duration ?? Duration.zero;

                        return Column(
                          children: [
                            Slider(
                              value: position.inMilliseconds.toDouble(),
                              max: duration.inMilliseconds.toDouble(),
                              onChanged: (value) {
                                _audioPlayer.seek(
                                    Duration(milliseconds: value.toInt()));
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(position)),
                                  Text(_formatDuration(duration)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(
                          Icons.skip_previous,
                          Colors.teal,
                          onPressed:
                              _currentIndex > 0 ? _playPreviousSong : null,
                        ),
                        const SizedBox(width: 20),
                        _buildControlButton(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          Colors.teal,
                          isLarge: true,
                          onPressed: () {
                            if (_isPlaying) {
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.play();
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildControlButton(
                          Icons.skip_next,
                          Colors.teal,
                          onPressed: _currentIndex < widget.fileNames.length - 1
                              ? _playNextSong
                              : null,
                        ),
                      ],
                    ),
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

  Widget _buildControlButton(
    IconData icon,
    Color color, {
    bool isLarge = false,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isLarge ? 64 : 48,
        height: isLarge ? 64 : 48,
        decoration: BoxDecoration(
          color: onPressed == null ? Colors.grey : color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isLarge ? 32 : 24,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
