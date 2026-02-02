import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/full_screen_video_player_screen.dart';

class PreviewVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const PreviewVideoPlayer({super.key, required this.videoUrl});

  @override
  State<PreviewVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<PreviewVideoPlayer> {
  late VideoPlayerController _controller;
  late ValueNotifier<bool> _isInitialized;

  @override
  void initState() {
    super.initState();
    _isInitialized = ValueNotifier(false);
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        _isInitialized.value = true;
      });
  }

  @override
  void didUpdateWidget(PreviewVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _isInitialized.value = false;
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _isInitialized.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isInitialized,
      builder: (context, isInitialized, child) {
        if (!isInitialized) {
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.dividerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, VideoPlayerValue value, child) {
                    return GestureDetector(
                      onTap: () {
                        value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Icon(
                            value.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            size: 45,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, VideoPlayerValue value, child) {
                    if (value.isPlaying) {
                      return Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            if (isInitialized) {
                              _controller.pause();
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FullScreenVideoPlayerScreen(
                                            videoUrl: widget.videoUrl,
                                          ),
                                    ),
                                  )
                                  .then((_) {
                                    // Optional: Resume or reset when returning?
                                    // Current behavior: Do nothing, let user press play.
                                  });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Time Display (Bottom Left)
                Positioned(
                  bottom: 20, // Above the progress indicator
                  left: 8,
                  child: ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, VideoPlayerValue value, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Progress Indicator
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.only(
                      top: 10,
                    ), // Increase touch target
                    colors: const VideoProgressColors(
                      playedColor: AppTheme.primaryThemeColor,
                      bufferedColor: Colors.transparent,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
