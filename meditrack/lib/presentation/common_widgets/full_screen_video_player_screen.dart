import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoPlayerScreen> createState() =>
      _FullScreenVideoPlayerScreenState();
}

class _FullScreenVideoPlayerScreenState
    extends State<FullScreenVideoPlayerScreen> {
  late VideoPlayerController _controller;
  late ValueNotifier<bool> _isInitialized;
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    _isInitialized = ValueNotifier(false);
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _isInitialized.value = true;
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _isInitialized.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _toggleRotation() {
    _isLandscape = !_isLandscape;

    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _isInitialized,
          builder: (context, isInitialized, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator()),

                // Controls overlay (Center Play/Pause)
                if (isInitialized)
                  Center(
                    child: ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        return GestureDetector(
                          onTap: () {
                            value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          },
                          child: Icon(
                            value.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            size: 45,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        );
                      },
                    ),
                  ),

                // Bottom Controls (Progress, Time)
                if (isInitialized)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: AppTheme.primaryThemeColor,
                            bufferedColor: Colors.transparent,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (context, VideoPlayerValue value, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(value.position),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  _formatDuration(value.duration),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                // Close button (Top Left)
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),

                // Rotation Toggle (Top Right)
                if (isInitialized)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: _toggleRotation,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        child: const Icon(
                          Icons.screen_rotation,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
