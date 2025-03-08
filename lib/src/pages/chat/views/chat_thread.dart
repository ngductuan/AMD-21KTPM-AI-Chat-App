import 'package:flutter/material.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key});

  static const String routeName = '/chat-thread';

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    String title = args['title'];
    String subtitle = args['subtitle'];

    return Scaffold(
      appBar: AppBar(title: Text("Detail Screen")),
      body: Center(
        child: Text("Title: $title"),
      ),
    );
  }
}
