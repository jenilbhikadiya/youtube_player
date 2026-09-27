import 'package:flutter/material.dart';

import 'video_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('In-App YouTube Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.smart_display_rounded, size: 96, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Tap play to watch the video',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            IconButton(
              iconSize: 96,
              color: Colors.red,
              icon: const Icon(Icons.play_circle_fill_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VideoScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
