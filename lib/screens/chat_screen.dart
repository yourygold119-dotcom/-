import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/translation_service.dart';

/// محادثات يوراء — ترجمة فورية حقيقية عبر ML Kit
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _translator = TranslationService.instance;

  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello my friend, how are you today?", isMe: false),
    ChatMessage(text: "أهلاً بك، أنا بخير الحمد لله!", isMe: true),
    ChatMessage(text: "Welcome to Yuraa Super App!", isMe: false),
  ];

  Future<void> _translateMessage(ChatMessage message) async {
    setState(() => message.isTranslating = true);
    // ترجمة حقيقية على الجهاز
    final translated = await _translator.translateToArabic(message.text);
    setState(() {
      message.isTranslating = false;
      message.translatedText = translated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final showTranslate = !msg.isMe &&
                  msg.translatedText.isEmpty &&
                  _translator.needsTranslation(msg.text);
              return Align(
                alignment:
                    msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: msg.isMe ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(msg.text,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87)),
                      if (msg.translatedText.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Divider(color: Colors.grey[400]),
                        Text("🌐 الترجمة: ${msg.translatedText}",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold)),
                      ],
                      if (showTranslate) ...[
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: msg.isTranslating
                                ? null
                                : () => _translateMessage(msg),
                            icon: msg.isTranslating
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.translate,
                                    size: 16, color: Colors.blue),
                            label: Text(
                              msg.isTranslating
                                  ? "جاري الترجمة..."
                                  : "ترجمة فورية",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Row(children: [
            IconButton(
                icon: const Icon(Icons.image, color: Colors.grey),
                onPressed: () {}),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                    hintText: "اكتب رسالتك هنا...", border: InputBorder.none),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  setState(() {
                    _messages.add(ChatMessage(
                        text: _messageController.text.trim(), isMe: true));
                    _messageController.clear();
                  });
                }
              },
            ),
          ]),
        ),
      ]),
    );
  }
}
