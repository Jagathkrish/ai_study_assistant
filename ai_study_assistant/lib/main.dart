import 'package:flutter/material.dart';
import 'screens/download_screen.dart'; // Point to your new folder

void main() {
  runApp(const AIStudyApp());
}

class AIStudyApp extends StatelessWidget {
  const AIStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline AI Tutor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ModelDownloadScreen(),
    );
  }
}
