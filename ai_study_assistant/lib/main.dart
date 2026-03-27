import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/download_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  // 1. Mandatory for reading storage and AI initialization
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize the offline database (Hive)
  await Hive.initFlutter();
  await Hive.openBox('chat_history');

  // 3. Wake up the Gemma Engine
  try {
    await FlutterGemma.initialize();
    print("✅ Gemma Engine Initialized");
  } catch (e) {
    print("❌ Error initializing AI: $e");
  }

  // 4. Check if the model is installed
  final prefs = await SharedPreferences.getInstance();
  final bool isDownloaded = prefs.getBool('isModelDownloaded') ?? false;

  runApp(AIStudyApp(isDownloaded: isDownloaded));
}

class AIStudyApp extends StatelessWidget {
  final bool isDownloaded;

  const AIStudyApp({super.key, required this.isDownloaded});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Study Assistant',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      // If installed, go to Chat. If not, go to the Setup/Download screen.
      home: isDownloaded ? const ChatScreen() : const ModelDownloadScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
