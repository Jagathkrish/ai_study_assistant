import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

  late Box _chatBox;

  String _selectedMode = 'Chat';
  final List<String> _modes = ['Chat', 'Summarize', 'Quiz', 'ELI5'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Connect to the Hive database box
    _chatBox = Hive.box('chat_history');
    _loadSavedMessages();
  }

  // Load chat history when the screen opens
  void _loadSavedMessages() {
    final savedData = _chatBox.get('messages', defaultValue: []);
    setState(() {
      for (var item in savedData) {
        _messages.add(Map<String, String>.from(item));
      }
    });
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  // Save chat history to local storage
  void _saveMessagesToDatabase() {
    _chatBox.put('messages', _messages);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final userText = _textController.text.trim();
    if (userText.isEmpty || _isLoading) return;

    // 1. Add User Message
    setState(() {
      _messages.add({"sender": "user", "text": userText});
      _isLoading = true;
    });

    _saveMessagesToDatabase();
    _textController.clear();
    _scrollToBottom();

    // 2. Build the Prompt
    String prompt = "";
    switch (_selectedMode) {
      case 'Summarize':
        prompt =
            "Summarize the following text in 3 concise bullet points:\n\n$userText";
        break;
      case 'Quiz':
        prompt =
            "Create 1 multiple-choice question based on the following text. Include options A, B, C, D and explicitly state the correct answer at the end:\n\n$userText";
        break;
      case 'ELI5':
        prompt =
            "Explain the following concept simply, as if I were 5 years old. Use an analogy:\n\n$userText";
        break;
      default:
        prompt = userText;
    }

    // 3. Send to AI
    final aiService = AIService();
    final aiResponse = await aiService.askGemma(prompt);

    // 4. Update UI with AI Response
    setState(() {
      _messages.add({"sender": "ai", "text": aiResponse});
      _isLoading = false;
    });

    _saveMessagesToDatabase();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'AI Study Assistant',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // -----------------------------
          // 1. Chat History Area
          // -----------------------------
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.80,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 14.0,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.shade600 : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      boxShadow: isUser
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: isUser
                        ? Text(
                            msg["text"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          )
                        : MarkdownBody(
                            data: msg["text"]!,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              listBullet: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                              h1: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              code: TextStyle(
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.red.shade800,
                                fontFamily: 'monospace',
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          // -----------------------------
          // 2. Mode Selectors
          // -----------------------------
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _modes.length,
              itemBuilder: (context, index) {
                final mode = _modes[index];
                final isSelected = _selectedMode == mode;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(
                      mode,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: Colors.blue.shade600,
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.blue.shade600
                            : Colors.grey.shade300,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected && !_isLoading) {
                        setState(() => _selectedMode = mode);
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // -----------------------------
          // 3. Input Field
          // -----------------------------
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 24.0,
              top: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: !_isLoading,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: _isLoading
                          ? 'Gemma is thinking...'
                          : 'Ask a question or paste text...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Container(
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? Colors.grey.shade400
                        : Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                    tooltip: 'Send Message',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
