import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:care/services/chatbot_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(
    id: 'user',
    firstName: 'You', // shows "Y" in default avatar
  );
  final _bot = const types.User(
    id: 'bot',
    firstName: 'Bot', // shows "B" in default avatar
  );
  final ChatbotService _chatbotService = ChatbotService();

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    final reply = await _chatbotService.sendMessage(message.text);

    final botMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: reply,
    );

    _addMessage(botMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light hospital feel
      appBar: AppBar(
        // Set AppBar background to match the Scaffold's background
        backgroundColor: const Color(0xFFE8F5E9),
        // Remove the shadow below the AppBar
        elevation: 0,
        // Set the color for the back arrow icon
        iconTheme: const IconThemeData(
          color: Color(0xFF00695C),
        ),
        title: const Text(
          "Health Chatbot",
          style: TextStyle(
            // Change title color to be visible on the new background
            color: Color(0xFF00695C),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      // The Chat widget should be the direct body.
      // This fixes the issue where messages would scroll behind the input box.
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: const DefaultChatTheme(
          backgroundColor: Color(0xFFE8F5E9),
          primaryColor: Color(0xFF00796B), // User messages teal
          secondaryColor: Color(0xFFB2DFDB), // Bot messages light teal

          // Input box customization
          inputBackgroundColor: Color(0xFF00695C),
          inputBorderRadius: BorderRadius.all(Radius.circular(25)),
          inputTextColor: Colors.white,
          inputTextStyle: TextStyle(fontSize: 18),
          inputPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),

          // Messages styling
          sentMessageBodyTextStyle:
              TextStyle(color: Colors.white, fontSize: 15),
          receivedMessageBodyTextStyle:
              TextStyle(color: Colors.black87, fontSize: 15),
          messageInsetsVertical: 8,
          messageInsetsHorizontal: 12,
        ),
      ),
    );
  }
}