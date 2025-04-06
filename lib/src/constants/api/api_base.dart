import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';

class ApiBase {
  // Base URLs
  static const authUrl = 'https://auth-api.dev.jarvis.cx';
  static const jarvisUrl = 'https://api.dev.jarvis.cx';
  static const knowledgeUrl = 'https://knowledge-api.dev.jarvis.cx';

  // Other URLs
  static const verificationCallbackUrl =
      'https://auth.dev.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.dev.jarvis.cx%252Fauth%252Foauth%252Fsuccess';
  static const headerAuth = {
    'X-Stack-Access-Type': 'client',
    'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
    'X-Stack-Publishable-Client-Key':
        'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
    'Content-Type': 'application/json',
  };

  bool isAccessTokenExpired(SharedPreferences prefs) {
    final expiryString = prefs.getString(LocalStorageKey.accessTokenExpiry);
    if (expiryString != null) {
      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiryTime);
    }
    return true; // Nếu không có thông tin expiry, mặc định coi là đã hết hạn
  }

  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(LocalStorageKey.refreshToken);

    // Giả sử API refresh được gọi tại endpoint dưới đây
    final url = Uri.parse('$authUrl/api/v1/auth/refresh');
    final response = await http.post(
      url,
      headers: {
        'x-jarvis-guid': 'c18d173d-bb4e-49f9-b4d8-f9a302bf89ff',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      final newAccessToken = responseJson[LocalStorageKey.accessToken];
      final newRefreshToken = responseJson[LocalStorageKey.refreshToken];

      // Cập nhật lại token và thời gian hết hạn (5 phút hoặc lấy từ API nếu có)
      final currentTime = DateTime.now();
      final newExpiryTime = currentTime.add(Duration(minutes: 5));

      await prefs.setString(LocalStorageKey.accessToken, newAccessToken);
      await prefs.setString(LocalStorageKey.refreshToken, newRefreshToken);
      await prefs.setString(
          LocalStorageKey.accessTokenExpiry, newExpiryTime.toIso8601String());
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  /// Hàm lấy header xác thực, kiểm tra và làm mới access token nếu cần
  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    if (isAccessTokenExpired(prefs)) {
      await refreshAccessToken();
    }
    final accessToken = prefs.getString(LocalStorageKey.accessToken);
    return {
      'x-jarvis-guid': 'c18d173d-bb4e-49f9-b4d8-f9a302bf89ff',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  /// Ví dụ về wrapper cho HTTP POST đã tích hợp refresh token
  Future<http.Response> authenticatedPost(String endpoint,
      {Map<String, dynamic>? body}) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('$jarvisUrl/$endpoint');
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  /// Wrapper cho HTTP GET
  Future<http.Response> authenticatedGet(Uri url) async {
    final headers = await getAuthHeaders();
    return await http.get(url, headers: headers);
  }

  /// Wrapper cho HTTP DELETE
  Future<http.Response> authenticatedDelete(Uri url) async {
    final headers = await getAuthHeaders();
    return await http.delete(url, headers: headers);
  }
}
