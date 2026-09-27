import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../widgets/quiz_overlay.dart';

/// Plays the given YouTube video entirely in-app (never navigates to the
/// YouTube app or website). Once playback reaches [_checkpointSeconds] the
/// video pauses and a confirmation quiz is shown above it; the quiz
/// auto-resolves after 10 seconds if the user doesn't answer, and playback
/// then resumes. The same checkpoint/quiz behaviour also applies when the
/// player is switched to fullscreen (landscape).
class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  static const _videoUrl = 'https://youtu.be/SA0CYhKEYQY?si=aUFBQhBMdYjBBTnq';
  static const _checkpointSeconds = 30;

  late final YoutubePlayerController _controller;
  late final StreamSubscription<YoutubeVideoState> _stateSubscription;

  bool _showQuiz = false;
  bool _quizTriggered = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayerController.convertUrlToId(_videoUrl)!;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        playsInline: true,
        mute: false,
      ),
    );

    _controller.setFullScreenListener((isFullScreen) {
      setState(() => _isFullScreen = isFullScreen);
    });

    _stateSubscription = _controller.videoStateStream.listen(_onVideoState);
  }

  void _onVideoState(YoutubeVideoState state) {
    if (!_quizTriggered && state.position.inSeconds >= _checkpointSeconds) {
      _quizTriggered = true;
      _controller.pauseVideo();
      _openQuizDialog();
    }
  }

  Future<void> _openQuizDialog() async {
    setState(() => _showQuiz = true);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) =>
          QuizOverlay(onResolved: _onQuizResolved, durationSeconds: 10),
    );
  }

  void _onQuizResolved(bool continueWatching) {
    Navigator.of(context).pop();
    setState(() => _showQuiz = false);
    _controller.playVideo();
  }

  /// Debug-only helper so the checkpoint/quiz/fullscreen behaviour can be
  /// exercised on an emulator without needing a real video to actually play
  /// (YouTube blocks embedded playback on emulators). Never shown in release
  /// builds.
  void _debugTriggerQuizNow() {
    if (_quizTriggered) return;
    _quizTriggered = true;
    _controller.pauseVideo();
    _openQuizDialog();
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final hideAppBar =
            _isFullScreen || orientation == Orientation.landscape;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: hideAppBar
              ? null
              : AppBar(
                  title: const Text('Video'),
                  backgroundColor: Colors.red,
                ),
          body: YoutubePlayerScaffold(
            controller: _controller,
            aspectRatio: 16 / 9,
            builder: (context, player) {
              return Column(
                children: [
                  player,
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Playback pauses once at 30 seconds for a quick '
                      'confirmation, then continues automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: (kDebugMode && !_showQuiz && !_quizTriggered)
              ? FloatingActionButton.extended(
                  onPressed: _debugTriggerQuizNow,
                  label: const Text('Test quiz now'),
                  icon: const Icon(Icons.bug_report),
                )
              : null,
        );
      },
    );
  }
}
