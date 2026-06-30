import 'package:flutter/material.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      "sender": "coach",
      "text": "Hi Alex! I notice you've snoozed the 'Compiler AST Parser' block twice today. Deadline is Friday.",
      "isCoaching": true
    },
    {
      "sender": "coach",
      "text": "Let's beat the friction. Can we commit to just 10 minutes to write the AST class definition? I'll set a focus block now.",
      "isCoaching": true
    }
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        "sender": "user",
        "text": _controller.text,
        "isCoaching": false
      });
      
      // Simulate Accountability Coach Response
      _messages.add({
        "sender": "coach",
        "text": "Excellent step! I have unlocked a 10-minute Focus Mode timer. Let's do it now.",
        "isCoaching": true,
        "actions": ["Start 10 Min Focus Now", "Maybe Later"]
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('LifeSaver AI Coach'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat Stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";
                final hasActions = msg["actions"] != null;

                return Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Chat Bubble
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? (index % 3 == 0
                                ? const Color(0xFF83A6CE)
                                : (index % 3 == 1 ? const Color(0xFFE5C9D7) : const Color(0xFFC48CB3)))
                            : (index % 2 == 0 ? const Color(0xFF0D1E4C) : const Color(0xFF26415E)),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 16),
                        ),
                        border: isUser ? null : Border.all(color: const Color(0xFF26415E), width: 1.5),
                      ),
                      child: Text(
                        msg["text"],
                        style: TextStyle(
                          color: isUser ? const Color(0xFF0B1B32) : Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                    
                    // Intervention Quick Actions
                    if (hasActions) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Wrap(
                          spacing: 8,
                          children: (msg["actions"] as List<String>).map((act) {
                            return ActionChip(
                              label: Text(act, style: const TextStyle(fontSize: 12)),
                              backgroundColor: colors.primary.withOpacity(0.1),
                              side: BorderSide(color: colors.primary),
                              onPressed: () {
                                if (act.contains("Start")) {
                                  Navigator.pushNamed(context, '/focus');
                                }
                              },
                            );
                          }).toList(),
                        ),
                      )
                    ]
                  ],
                );
              },
            ),
          ),
          
          // Input bar
          Container(
            padding: const EdgeInsets.all(16),
            color: colors.surface.withOpacity(0.5),
            child: Row(
              children: [
                // Voice Command Button
                IconButton(
                  icon: Icon(Icons.mic, color: colors.secondary),
                  onPressed: () {
                    // Simulate Voice Command
                    setState(() {
                      _controller.text = "I have a chemistry test next Tuesday";
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Talk to coach or add tasks...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: colors.primary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
