import 'dart:convert';
import 'dart:io';

import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/constants/services/bot.service.dart';
import 'package:http/http.dart' as http;

class ChatServiceApi {
  static Future<dynamic> getChatHistory() async {
    final url = Uri.parse('${ApiBase.jarvisUrl}/api/v1/ai-chat/conversations').replace(
      queryParameters: {'assistantId': 'gpt-4o-mini', 'assistantModel': 'dify'},
    );

    final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

    return await http.get(url, headers: headers).then((response) {
      if (response.statusCode == HttpStatus.ok) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load chat history : ${response.reasonPhrase}');
      }
    });
  }

  //   static Future<dynamic> getChatHistory(String conversationId, {int offset = 0, int limit = 10}) async {
  //   final url = Uri.parse('${ApiBase.jarvisUrl}/api/v1/ai-chat/conversations/$conversationId/messages').replace(
  //     queryParameters: {
  //       'assistantId': 'gpt-4o-mini',
  //       'assistantModel': 'dify'
  //     },
  //   );

  //   final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

  //   return await http.get(url, headers: headers).then((response) {
  //     if (response.statusCode == HttpStatus.ok) {
  //       return jsonDecode(response.body) as Map<String, dynamic>;
  //     } else {
  //       throw Exception('Failed to load chat history for conversation $conversationId : ${response.reasonPhrase}');
  //     }
  //   });
  // }

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

    final encodedBody = body is String ? body : jsonEncode(body);

    return await http.post(url, headers: headers, body: encodedBody).then((response) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.unprocessableEntity) {
        return response;
      } else {
        throw Exception('Failed to load bot response: ${response.reasonPhrase}');
      }
    });
  }
}
