import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const ai = User(id: 'gemini');
const user = User(id: 'user');

class HomePage extends HookWidget {
  HomePage({super.key});

  final chat = useState<ChatSession?>(null);
  final messages = useState<List<types.Message>>([]);

  void addMessage(User author, String text) {
    final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    final message = types.TextMessage(
      author: author,
      id: timeStamp,
      text: text,
    );
    messages.value = [message, ...messages.value];
  }

  Future<void> onSendPressed(PartialText text) async {
    addMessage(user, text.text);

    final content = Content.text(text.text);
    try {
      final response = await chat.value?.sendMessage(content);
      final message = response?.text ?? 'エラーが発生しました';
      addMessage(ai, message);
    } on Exception catch (err) {
      final isOverloaded = err.toString().contains('overloaded');
      final message =
          isOverloaded ? '混雑しています。しばらくしてからもう一度お試しください。' : 'エラーが発生しました';
      addMessage(ai, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      Future<void> setupChat() async {
        final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: dotenv.get('GEMINI_API_KEY'),
        );
        final session = await model.startChat();
        chat.value = session;
      }

      setupChat();
      return () {};
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Free Chat GPT"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Chat(
        user: user,
        messages: messages.value,
        onSendPressed: onSendPressed,
        inputOptions: const InputOptions(
          autofocus: true,
        ),
        emptyState: const Center(
          child: Text(
            "What can I help you with today?",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
