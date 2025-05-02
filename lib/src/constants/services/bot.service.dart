import 'dart:convert';
import 'dart:io';

import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:http/http.dart' as http;

class BotServiceApi {
  static final assistant = {
    "model": "knowledge-base",
    "name": "votutrinh2002's Default Team Assistant",
    "id": "29178123-34d4-4e52-94fb-8e580face2d5"
  };

  static Future<dynamic> createBotResponse(Map<String, dynamic>? body) async {
    final url = Uri.parse('${ApiBase.knowledgeUrl}/kb-core/v1/ai-assistant');

    final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

    final encodedBody = body is String ? body : jsonEncode(body);

    return await http.post(url, headers: headers, body: encodedBody).then((response) {
      if (response.statusCode == HttpStatus.created) {
        return response.body;
      } else {
        throw Exception('Failed to load bot response: ${response.reasonPhrase}');
      }
    });
  }

  static Future<dynamic> getAllBots({int offset = 0, int limit = 10, String? search}) async {
    final url = Uri.parse('${ApiBase.knowledgeUrl}/kb-core/v1/ai-assistant').replace(
      queryParameters: {
        'q': search,
        'order': 'DESC',
        'order_field': 'createdAt',
        'offset': offset.toString(),
        'limit': limit.toString(),
        'is_published': null,
      },
    );

    final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

    return await http.get(url, headers: headers).then((response) {
      if (response.statusCode == HttpStatus.ok) {
        return response.body;
      } else {
        throw Exception('Failed to load bots: ${response.reasonPhrase}');
      }
    });
  }

  static Future<dynamic> getBotById(String assistantId) async {
    final url = Uri.parse('${ApiBase.knowledgeUrl}/kb-core/v1/ai-assistant/$assistantId');

    final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

    return await http.get(url, headers: headers).then((response) {
      if (response.statusCode == HttpStatus.ok) {
        return response.body;
      } else {
        throw Exception('Failed to load bot by ID $assistantId : ${response.reasonPhrase}');
      }
    });
  }

  static Future<dynamic> updateBotById(String assistantId, Map<String, dynamic>? body) async {
    final url = Uri.parse('${ApiBase.knowledgeUrl}/kb-core/v1/ai-assistant/$assistantId');

    final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

    final encodedBody = body is String ? body : jsonEncode(body);

    return await http.patch(url, headers: headers, body: encodedBody).then((response) {
      if (response.statusCode == HttpStatus.ok) {
        return response.body;
      } else {
        throw Exception('Failed to load bot by ID $assistantId : ${response.reasonPhrase}');
      }
    });
  }
}
