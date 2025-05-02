import 'dart:convert';
import 'dart:io';

import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/constants/services/bot.service.dart';
import 'package:http/http.dart' as http;

class ChatServiceApi {
  static Future<dynamic> createChatWithBot(String content, List<Map<String, dynamic>>? historyMsg) async {
    final url = Uri.parse('${ApiBase.jarvisUrl}/api/v1/ai-chat/messages');

    final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

    final body = {
      "content": content,
      "files": [],
      "metadata": {
        "conversation": {"messages": historyMsg},
      },
      "assistant": BotServiceApi.assistant
    };

    print('body: $body');

    final encodedBody = body is String ? body : jsonEncode(body);

    return await http.post(url, headers: headers, body: encodedBody).then((response) {
      if (response.statusCode == HttpStatus.ok) {
        return response.body;
      } else {
        throw Exception('Failed to load bot response: ${response.reasonPhrase}');
      }
    });
  }
}
