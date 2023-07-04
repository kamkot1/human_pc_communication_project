//model.dart
enum ChatMessageType { user, bot }

class ChatMessage {
  final String text;
  final ChatMessageType chatMessageType;
  final bool wasVoiceInput;

  ChatMessage(
      {required this.text,
      required this.chatMessageType,
      required this.wasVoiceInput});

  static fromMap(jsonDecode) {}
}
