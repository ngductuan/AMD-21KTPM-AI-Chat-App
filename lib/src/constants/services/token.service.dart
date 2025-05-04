import 'dart:io';

import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:http/http.dart' as http;

class TokenServiceApi {
  static Future<dynamic> getTokenUsage() async {
    final url = Uri.parse('${ApiBase.jarvisUrl}/api/v1/tokens/usage');

    final Map<String, String> headers = await apiBaseInstance.getAuthHeaders();

    return await http.get(url, headers: headers).then((response) {
      if (response.statusCode == HttpStatus.ok) {
        return response.body;
      } else {
        throw Exception('Failed to load token usage: ${response.reasonPhrase}');
      }
    });
  }
}
