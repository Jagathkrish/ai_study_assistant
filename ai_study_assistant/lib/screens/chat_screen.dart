import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  // 1. Add a variable to track the active mode
  String _selectedMode = 'Chat';
  final List<String> _modes = ['Chat', 'Summarize', 'Quiz', 'ELI5'];

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      // Attach the selected mode to the user's input so we know what they asked for
      String userText = "[${_selectedMode}] ${_textController.text}";
      _messages.add({"sender": "user", "text": userText});

      _messages.add({
        "sender": "ai",
        "text": "This is a placeholder for the $_selectedMode response.",
      });
    });

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Study Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(msg["text"]!),
                  ),
                );
              },
            ),
          ),

          // 2. Add the Mode Selectors here
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _modes.length,
              itemBuilder: (context, index) {
                final mode = _modes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(mode),
                    selected: _selectedMode == mode,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedMode = mode);
                      }
                    },
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question or paste text...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
