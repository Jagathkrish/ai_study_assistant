import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import the chat screen

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen> {
  double downloadProgress = 0.0;

  Future<void> startDownload() async {
    // Simulating download progress
    setState(() {
      downloadProgress = 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download AI Model')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Download Progress: ${(downloadProgress * 100).toInt()}%'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: startDownload,
              child: const Text('Start Download'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              child: const Text('Go to Chat'),
            ),
          ],
        ),
      ),
    );
  }
}