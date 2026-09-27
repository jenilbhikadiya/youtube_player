import 'dart:async';

import 'package:flutter/material.dart';

/// Confirmation quiz shown on top of the video player.
///
/// Counts down from [durationSeconds] and calls [onResolved] either when the
/// user taps Yes/No or when the countdown reaches zero, whichever happens
/// first.
class QuizOverlay extends StatefulWidget {
  const QuizOverlay({
    super.key,
    required this.onResolved,
    this.durationSeconds = 10,
  });

  final ValueChanged<bool> onResolved;
  final int durationSeconds;

  @override
  State<QuizOverlay> createState() => _QuizOverlayState();
}

class _QuizOverlayState extends State<QuizOverlay> {
  late int _secondsLeft = widget.durationSeconds;
  Timer? _timer;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        _resolve(true);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _resolve(bool continueWatching) {
    if (_resolved) return;
    _resolved = true;
    _timer?.cancel();
    widget.onResolved(continueWatching);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Card(
          color: Colors.white,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to continue watching?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Auto-continue in $_secondsLeft s',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _resolve(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Yes'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _resolve(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('No'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
