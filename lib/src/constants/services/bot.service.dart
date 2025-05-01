import 'dart:convert';
import 'dart:io';

import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:http/http.dart' as http;

class BotServiceApi {
  static Future<dynamic> createBotResponse(Map<String, dynamic>? body) async {
    final url = Uri.parse('${ApiBase.knowledgeUrl}/kb-core/v1/ai-assistant');

    final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

    headers['Content-Type'] = 'application/json';

    final encodedBody = body is String ? body : jsonEncode(body);

    return await http.post(url, headers: headers, body: encodedBody).then((response) {
      if (response.statusCode == HttpStatus.created) {
        return response.body;
      } else {
        throw Exception('Failed to load bot response: ${response.reasonPhrase}');
      }
    });
  }
}
