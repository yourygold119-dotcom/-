/// نموذج الرسالة الواحدة في محادثات يوراء
class ChatMessage {
  final String text;
  final bool isMe;
  String translatedText; // النص المترجم
  bool isTranslating;

  ChatMessage({
    required this.text,
    required this.isMe,
    this.translatedText = "",
    this.isTranslating = false,
  });
}
