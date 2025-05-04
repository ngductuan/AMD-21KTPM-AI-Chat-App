import 'dart:convert';
import 'dart:io';

import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:http/http.dart' as http;

class KnowledgeServiceApi {
  // Get Imported Knowledge In Assistant
  static Future<dynamic> getImportedSourceByBotId(String assistantId,
      {int offset = 0, int limit = 10, String? search}) async {
    final url = Uri.parse('${ApiBase.knowledgeUrl}/kb-core/v1/ai-assistant/$assistantId/knowledges').replace(
      queryParameters: {
        'q': search,
        'order': 'DESC',
        'order_field': 'createdAt',
        'offset': offset.toString(),
        'limit': limit.toString()
      },
    );

    final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

    return await http.get(url, headers: headers).then((response) {
      if (response.statusCode == HttpStatus.ok) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load imported knowledge by bot ID $assistantId : ${response.reasonPhrase}');
      }
    });
  }
}
