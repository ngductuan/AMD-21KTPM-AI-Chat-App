import 'dart:convert';
import 'package:eco_chat_bot/src/constants/api/env_key.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiBase {
  // Base URLs
  static final authUrl = dotenv.maybeGet(EnvKey.authApi) ?? 'https://auth-api.dev.jarvis.cx';
  static final jarvisUrl = dotenv.maybeGet(EnvKey.jarvisApi) ?? 'https://api.dev.jarvis.cx';
  static final knowledgeUrl = dotenv.maybeGet(EnvKey.knowledgeApi) ?? 'https://knowledge-api.dev.jarvis.cx';

  // Other URLs
  static const verificationCallbackUrl =
      'https://auth.dev.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.dev.jarvis.cx%252Fauth%252Foauth%252Fsuccess';
  static const headerAuth = {
    'X-Stack-Access-Type': 'client',
    'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
    'X-Stack-Publishable-Client-Key': 'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
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

    // Endpoint mới cho refresh token
    final url = Uri.parse('$authUrl/api/v1/auth/sessions/current/refresh');

    // Header theo yêu cầu
    final headers = {
      'X-Stack-Access-Type': 'client',
      'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
      'X-Stack-Publishable-Client-Key': 'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
      'X-Stack-Refresh-Token': refreshToken ?? '',
    };

    // Tạo request POST
    final request = http.Request('POST', url);
    request.headers.addAll(headers);

    // Gửi request và chuyển đổi response từ stream thành http.Response
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      final newAccessToken = responseJson['access_token'];

      // Giả định access token có hiệu lực 5 phút (có thể thay đổi tùy API)
      final newExpiryTime = DateTime.now().add(Duration(minutes: 5));

      // Cập nhật access token và thời gian hết hạn
      await prefs.setString(LocalStorageKey.accessToken, newAccessToken);
      await prefs.setString(LocalStorageKey.accessTokenExpiry, newExpiryTime.toIso8601String());
      print('Access token refreshed successfully');
    } else {
      throw Exception('Failed to refresh token: ${response.reasonPhrase}');
    }
  }

  /// Hàm lấy header xác thực, kiểm tra và làm mới access token nếu cần
  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    if (isAccessTokenExpired(prefs)) {
      await refreshAccessToken();
      print('Access token expired, refreshed successfully');
    }
    print('Access token is valid');
    final accessToken = prefs.getString(LocalStorageKey.accessToken);
    return {
      'x-jarvis-guid': 'c18d173d-bb4e-49f9-b4d8-f9a302bf89ff',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  /// Ví dụ về wrapper cho HTTP POST đã tích hợp refresh token
  Future<http.Response> authenticatedPost(String endpoint, {Map<String, dynamic>? body}) async {
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

final apiBaseInstance = ApiBase();