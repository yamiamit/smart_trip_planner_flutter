abstract class ChatEvent {}

class ChatPromptSubmitted extends ChatEvent {
  final String prompt;
  ChatPromptSubmitted(this.prompt);
}
