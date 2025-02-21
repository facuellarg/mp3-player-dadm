import 'dart:io';
import 'songs.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class MusicPlayerView extends StatefulWidget {
  final Object fileName;
  _MusicPlayerView(Object fileName) {
    throw UnimplementedError();
  }

  const MusicPlayerView(FileSystemEntity file,
      {Key? key, required this.fileName})
      : super(key: key);

  @override
  State<MusicPlayerView> createState() => _MusicPlayerViewState(fileName);
}

class _MusicPlayerViewState extends State<MusicPlayerView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  
  _MusicPlayerViewState(Object fileName);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    print("Init");
    print(widget.fileName);    
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.fileName.toString()),
        ),
      );

      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.playing != _isPlaying) {
          setState(() {
            _isPlaying = playerState.playing;
          });
        }
      });
    } catch (e) {
      debugPrint("Error cargando el audio: $e");
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
    print("Context");
    print(context);    
    return Scaffold(
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
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Music notes animation container
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: CustomPaint(
                painter: MusicNotesPainter(),
                child: Container(),
              ),
            ),
          ),

          // Player controls
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Song title and artist
                Text(
                  widget.fileName.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Amy Winehouse',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),

                // Progress bar
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
                            _audioPlayer
                                .seek(Duration(milliseconds: value.toInt()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                const SizedBox(height: 20),

                // Player controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      Icons.skip_previous,
                      Colors.teal,
                      onPressed: () => _audioPlayer.seekToPrevious(),
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
                      onPressed: () => _audioPlayer.seekToNext(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom navigation
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // _buildNavItem(Icons.music_note, 'Music'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SongsScreen()),
                    );
                  },
                  child: _buildNavItem(Icons.music_note, 'Music'),
                  // return const MaterialApp(
                  //   home: Scaffold(
                  //     body: Center(
                  //       child: MusicPlayerView(),
                  //     ),
                ),

                _buildNavItem(Icons.favorite_border, 'Favorite'),
                _buildNavItem(Icons.playlist_play, 'Playlist'),
              ],
            ),
          ),
        ],
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
          color: color,
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

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
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

// Custom painter for music notes animation
class MusicNotesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.teal.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final Path notePath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width * 0.8,
        size.height * 0.5,
      );

    canvas.drawPath(notePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
