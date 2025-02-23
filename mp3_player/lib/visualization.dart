import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const AudioVisualizer({
    Key? key,
    required this.audioPlayer,
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late List<double> barHeights;
  late Timer timer;
  final random = Random();
  final int barsCount = 32;

  @override
  void initState() {
    super.initState();
    barHeights = List.filled(barsCount, 0.0);
    _startAnimation();
  }

  void _startAnimation() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!widget.audioPlayer.playing) {
        setState(() {
          barHeights = List.filled(barsCount, 0.2);
        });
        return;
      }

      setState(() {
        for (var i = 0; i < barsCount; i++) {
          // Create a smoother transition by using the previous height
          final targetHeight = 0.2 + random.nextDouble() * 0.8;
          barHeights[i] = (barHeights[i] + targetHeight) / 2;
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          barsCount,
          (index) => _buildBar(barHeights[index]),
        ),
      ),
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) / barsCount - 2,
      height: 150 * height,
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// class AudioWaveformWidget extends StatefulWidget {
//   final AudioPlayer audioPlayer;
//   final String audioFile;

//   const AudioWaveformWidget({
//     Key? key,
//     required this.audioPlayer,
//     required this.audioFile,
//   }) : super(key: key);

//   @override
//   State<AudioWaveformWidget> createState() => _AudioWaveformWidgetState();
// }

// class _AudioWaveformWidgetState extends State<AudioWaveformWidget> {
//   late PlayerController controller;
//   bool isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     controller = PlayerController();
//     // Defer initialization until after build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeController();
//     });
//   }

//   void _initializeController() async {
//     try {
//       // Extract file path from the URI
//       final filePath = Uri.parse(widget.audioFile).toFilePath();
//       await controller.preparePlayer(
//         path: filePath,
//         noOfSamples: MediaQuery.of(context).size.width.toInt() ~/ 2,
//       );

//       if (mounted) {
//         setState(() {
//           isInitialized = true;
//         });
//       }

//       // Sync with the main audio player
//       widget.audioPlayer.playerStateStream.listen((state) {
//         if (state.playing) {
//           controller.startPlayer();
//         } else {
//           controller.pausePlayer();
//         }
//       });

//       widget.audioPlayer.positionStream.listen((position) {
//         controller.seekTo(position.inMilliseconds);
//       });
//     } catch (e) {
//       debugPrint("Error initializing waveform: $e");
//     }
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!isInitialized) {
//       return Container(
//         height: 200,
//         alignment: Alignment.center,
//         child: const CircularProgressIndicator(),
//       );
//     }

//     return AudioFileWaveforms(
//       size: Size(MediaQuery.of(context).size.width, 200),
//       playerController: controller,
//       enableSeekGesture: true,
//       waveformType: WaveformType.fitWidth,
//       playerWaveStyle: const PlayerWaveStyle(
//         fixedWaveColor: Colors.teal,
//         liveWaveColor: Colors.tealAccent,
//         spacing: 6,
//         showBottom: true,
//         showSeekLine: false,
//         waveCap: StrokeCap.round,
//       ),
//     );
//   }
// }
