import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart'; // Import the real AI service
import 'chat_screen.dart';

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  String _statusMessage =
      'Downloading the offline model (1.3GB).\nThis only happens once.';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- THIS IS THE UPDATED FUNCTION ---
  void _startRealModelInstall() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.3; // Show initial progress
      _statusMessage = 'Unpacking AI Model to Memory...';
    });

    try {
      // 1. Call your real AI Service to install the 1.3GB model
      final aiService = AIService();
      await aiService.initAI();

      setState(() {
        _progress = 1.0;
        _isDownloading = false;
        _isDownloaded = true;
        _statusMessage = 'Initialization complete! Launching...';
      });

      // 2. Save the success flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isModelDownloaded', true);

      // 3. Navigate to Chat after a brief pause for user experience
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        }
      });
    } catch (e) {
      // If something goes wrong (e.g., out of storage space)
      setState(() {
        _isDownloading = false;
        _statusMessage = 'Error loading AI.\nPlease check storage and restart.';
      });
      print("Installation Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      size: 64,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  'AI Engine Setup',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _statusMessage, // Using dynamic status message now
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: !_isDownloading && !_isDownloaded
                      ? SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            // POINTING TO THE REAL FUNCTION NOW
                            onPressed: _startRealModelInstall,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Install AI Engine',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          key: const ValueKey('progress_bar'),
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: _progress == 0.0
                                    ? null
                                    : _progress, // Shows indeterminate spinning until done
                                minHeight: 12,
                                backgroundColor: Colors.blue.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.shade600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isDownloaded ? 'Complete' : 'Installing...',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _isDownloaded ? '100%' : '...',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
