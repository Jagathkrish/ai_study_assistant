import 'package:flutter_gemma/flutter_gemma.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Updated variable name
  bool _isModelInstalled = false;

  // Updated method name
  Future<void> initAI() async {
    if (_isModelInstalled) return;

    try {
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.task,
      ).fromAsset('assets/models/gemma-2b-it-cpu-int8.task').install();

      _isModelInstalled = true;
      print("🚀 Model successfully installed from assets!");
    } catch (e) {
      print("❌ Model Installation Error: $e");
    }
  }

  Future<String> askGemma(String prompt) async {
    // THIS LINE IS FIXED: It now uses the updated names!
    if (!_isModelInstalled) await initAI();

    try {
      final model = await FlutterGemma.getActiveModel(maxTokens: 512);
      final session = await model.createSession();

      await session.addQueryChunk(Message.text(text: prompt, isUser: true));
      final response = await session.getResponse();

      await session.close();
      return response ?? "No response generated.";
    } catch (e) {
      print("AI Error: $e");
      return "Something went wrong: $e";
    }
  }
}
