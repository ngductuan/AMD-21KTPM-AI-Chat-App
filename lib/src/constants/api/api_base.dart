import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';
import 'package:flutter/foundation.dart';

class ApiBase {
  // Base URLs
  static final authUrl = 'https://auth-api.dev.jarvis.cx';
  static final jarvisUrl = 'https://api.dev.jarvis.cx';
  static final knowledgeUrl = 'https://knowledge-api.dev.jarvis.cx';

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

    // Endpoint mới cho refresh token
    final url = Uri.parse('$authUrl/api/v1/auth/sessions/current/refresh');

    // Header theo yêu cầu
    final headers = {
      'X-Stack-Access-Type': 'client',
      'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
      'X-Stack-Publishable-Client-Key':
          'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
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
      await prefs.setString(
          LocalStorageKey.accessTokenExpiry, newExpiryTime.toIso8601String());
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

  /// CÁC API TẠO BỘ DỮ LIỆU TRI THỨC ///

  // Tạo một bộ dữ liệu tri thức mới trên Knowledge API
  // Tham số:
  // - [knowledgeName]: Tên bộ tri thức mới
  // - [description]: mô tả tri thức mới
  Future<Map<String, dynamic>> createKnowledge({
    required String knowledgeName,
    required String description,
  }) async {
    // Lấy header (bao gồm Bearer token)
    final headers = await getAuthHeaders();

    // Endpoint của Knowledge API
    final url = Uri.parse('$knowledgeUrl/kb-core/v1/knowledge');

    // Chuẩn bị body
    final body = jsonEncode({
      'knowledgeName': knowledgeName,
      'description': description,
    });

    // Gửi POST
    final response = await http.post(url, headers: headers, body: body);

    // Xử lý kết quả
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to create knowledge: [${response.statusCode}] ${response.reasonPhrase}\n'
          'Body: ${response.body}');
    }
  }

  // API Hiển thị/tìm kiếm bộ dữ liệu tri thức
  // Tham số:
  // - [q]: chuỗi tìm kiếm (mặc định là rỗng để lấy tất cả)
  // - [order]: thứ tự sắp xếp, "ASC" hoặc "DESC" (mặc định "DESC")
  // - [orderField]: trường để sắp xếp (mặc định "createdAt")
  // - [offset]: chỉ số bắt đầu (mặc định 0)
  // - [limit]: số phần tử trả về (mặc định 20)
  Future<Map<String, dynamic>> getKnowledges({
    String q = '',
    String order = 'DESC',
    String orderField = 'createdAt',
    int offset = 0,
    int limit = 20,
  }) async {
    // Lấy header (bao gồm Bearer token)
    final headers = await getAuthHeaders();

    // Xây dựng URI với query parameters
    final uri = Uri.parse('$knowledgeUrl/kb-core/v1/knowledge').replace(
      queryParameters: {
        'q': q,
        'order': order,
        'order_field': orderField,
        'offset': offset.toString(),
        'limit': limit.toString(),
      },
    );

    // Gửi GET
    final response = await http.get(uri, headers: headers);
    //debugPrint("Get knowledge:" + response.body);
    // Xử lý kết quả
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to fetch knowledges: [${response.statusCode}] ${response.reasonPhrase}\n'
          'Body: ${response.body}');
    }
  }

  // API Lấy đơn vị tri thức của một kiến thức
  Future<Map<String, dynamic>> getKnowledgeUnits({
    required String knowledgeId,
    String q = '',
    String order = 'DESC',
    String orderField = 'createdAt',
    int offset = 0,
    int limit = 20,
  }) async {
    final headers = await getAuthHeaders();
    final uri =
        Uri.parse('$knowledgeUrl/kb-core/v1/knowledge/$knowledgeId/units')
            .replace(
      queryParameters: {
        'q': q,
        'order': order,
        'order_field': orderField,
        'offset': offset.toString(),
        'limit': limit.toString(),
      },
    );
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to fetch knowledge units: [${response.statusCode}] ${response.reasonPhrase}\n'
          'Body: ${response.body}');
    }
  }

  // API Lấy đơn vị tri thức của một kiến thức
  Future<Map<String, dynamic>> getKnowledgeUnits({
    required String knowledgeId,
    String q = '',
    String order = 'DESC',
    String orderField = 'createdAt',
    int offset = 0,
    int limit = 20,
  }) async {
    final headers = await getAuthHeaders();
    final uri =
        Uri.parse('$knowledgeUrl/kb-core/v1/knowledge/$knowledgeId/units')
            .replace(
      queryParameters: {
        'q': q,
        'order': order,
        'order_field': orderField,
        'offset': offset.toString(),
        'limit': limit.toString(),
      },
    );
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to fetch knowledge units: [${response.statusCode}] ${response.reasonPhrase}\n'
          'Body: ${response.body}');
    }
  }

  // Xóa (disable) một bộ dữ liệu tri thức theo ID
  // Trả về `true` nếu xóa thành công, ngược lại ném Exception.
  Future<bool> deleteKnowledge(String knowledgeId) async {
    // Lấy header (bao gồm Bearer token)
    final headers = await getAuthHeaders();

    // Endpoint DELETE với path parameter là knowledgeId
    final uri = Uri.parse('$knowledgeUrl/kb-core/v1/knowledge/$knowledgeId');

    // Gửi DELETE
    final response = await http.delete(uri, headers: headers);

    // Xử lý kết quả
    if (response.statusCode == 200 || response.statusCode == 201) {
      // API trả về body là "true" hoặc "false"
      final result = jsonDecode(response.body) as bool;
      return result;
    } else {
      throw Exception(
        'Failed to delete knowledge: [${response.statusCode}] ${response.reasonPhrase}',
      );
    }
  }

  // Upload một file lên nguồn tri thức đã tạo
  // Tham số:
  //    - [knowledgeId]: ID của knowledge cần nạp file
  //    - [filePath]: đường dẫn local đến file cần upload
  //    -Trả về JSON của Knowledge Data Source nếu thành công
  Future<Map<String, dynamic>> uploadKnowledgeLocalFile({
    required String knowledgeId,
    required String filePath,
  }) async {
    // 1) Get auth headers
    final headers = await getAuthHeaders();
    // MultipartRequest will set its own Content-Type, so remove JSON header:
    headers.remove('Content-Type');

    // 2) Build URI
    final uri = Uri.parse(
      '$knowledgeUrl/kb-core/v1/knowledge/$knowledgeId/local-file',
    );

    // 3) Detect the file's MIME type from its extension:
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
    final parts = mimeType.split('/');
    final mediaType = MediaType(parts[0], parts[1]);

    // 4) Create & attach the multipart file with explicit contentType:
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: mediaType,
        ),
      );

    // 5) Send & parse response
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    // debugPrint('uploadKnowledgeLocalFile resp: ${resp.statusCode} ${resp.body}');

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to upload local file: [${resp.statusCode}] ${resp.reasonPhrase}\n'
        'Body: ${resp.body}',
      );
    }
  }

  // Upload dữ liệu từ URL website vào nguồn tri thức
  // Tham số:
  //  + [knowledgeId]: ID của knowledge cần nạp
  //  + [unitName]: tên đơn vị (unit) hiển thị trong tri thức
  //  + [webUrl]: địa chỉ website cần crawl
  //  + Trả về JSON của Knowledge Data Source nếu thành công
  Future<Map<String, dynamic>> uploadKnowledgeFromWeb({
    required String knowledgeId,
    required String unitName,
    required String webUrl,
  }) async {
    // 1. Lấy header (Bearer token)
    final headers = await getAuthHeaders();
    // Content-Type JSON
    headers['Content-Type'] = 'application/json';

    // 2. Build URI
    final uri = Uri.parse(
      '$knowledgeUrl/kb-core/v1/knowledge/$knowledgeId/web',
    );

    // 3. Chuẩn bị body JSON
    final body = jsonEncode({
      'unitName': unitName,
      'webUrl': webUrl,
    });
    debugPrint('Headers: ${headers.toString()}');
    debugPrint('Web body: ${body}');
    debugPrint('Knowledge id: ${knowledgeId}');

    // Gửi POST
    final response = await http.post(uri, headers: headers, body: body);
    // ===== ĐỔI PHẦN LOGGING =====
    debugPrint('–– Response status: ${response.statusCode}');
    // Với JSON dài, bạn có thể tăng wrapWidth để không bị cắt ngắn
    debugPrint('–– Response body: ${response.body}', wrapWidth: 2048);

    // Xử lý kết quả
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // Nếu API lỗi, in luôn cả body để xem chi tiết
      throw Exception(
        'Failed to upload knowledge from web: '
        '[${response.statusCode}] ${response.reasonPhrase}\n'
        'Body: ${response.body}',
      );
    }
  }

  // Upload dữ liệu từ Google Drive vào nguồn tri thức
  Future<Map<String, dynamic>> uploadKnowledgeFromGoogleDrive({
    required String knowledgeId,
    required String googleDriveToken,
  }) async {
    // 1) Lấy header (Bearer token + x-jarvis-guid)
    final headers = await getAuthHeaders();
    // MultipartRequest tự set Content-Type, nên gỡ bỏ nếu có
    headers.remove('Content-Type');

    // 2) Khởi tạo MultipartRequest
    final uri = Uri.parse(
      '$knowledgeUrl/kb-core/v1/knowledge/$knowledgeId/google-drive',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      // 3) Đính token vào field (hoặc bạn có thể dùng header tuỳ backend)
      ..fields['driveToken'] = googleDriveToken;

    // 4) Gửi và chờ response
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    // 5) Xử lý kết quả
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to import from Drive: [${response.statusCode}] '
        '${response.reasonPhrase}\nBody: ${response.body}',
      );
    }
  }

  // Upload dữ liệu từ Slack vào một Knowledge đã tạo
  // Tham số:
  //  + [knowledgeId]: ID của knowledge cần nạp
  //  + [unitName]: tên đơn vị (unit) hiển thị trong tri thức
  //  + [slackWorkspace]: tên workspace trên Slack
  //  + [slackBotToken]: Bot token để truy cập Slack API
  //  Trả về JSON của Knowledge Data Source nếu thành công
  Future<Map<String, dynamic>> uploadKnowledgeFromSlack({
    required String knowledgeId,
    required String unitName,
    required String slackWorkspace,
    required String slackBotToken,
  }) async {
    // 1. Lấy header (Bearer token + x-jarvis-guid)
    final headers = await getAuthHeaders();
    // Đảm bảo Content-Type là JSON
    headers['Content-Type'] = 'application/json';

    // 2. Build URI
    final uri = Uri.parse(
      '$knowledgeUrl/kb-core/v1/knowledge/$knowledgeId/slack',
    );

    // 3. Chuẩn bị body JSON
    final body = jsonEncode({
      'unitName': unitName,
      'slackWorkspace': slackWorkspace,
      'slackBotToken': slackBotToken,
    });

    // 4. Gửi POST
    final response = await http.post(uri, headers: headers, body: body);

    // 5. Xử lý kết quả
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to upload knowledge from Slack: [${response.statusCode}] ${response.reasonPhrase}',
      );
    }
  }

  // Upload dữ liệu từ Confluence vào một Knowledge đã tạo
  // Tham số:
  //  + [knowledgeId]: ID của knowledge cần nạp
  //  + [unitName]: tên đơn vị (unit) hiển thị trong tri thức
  //  + [wikiPageUrl]: URL trang Confluence cần crawl
  //  + [confluenceUsername]: username để truy cập Confluence
  //  + [confluenceAccessToken]: token truy cập Confluence
  // Trả về JSON của Knowledge Data Source nếu thành công
  Future<Map<String, dynamic>> uploadKnowledgeFromConfluence({
    required String knowledgeId,
    required String unitName,
    required String wikiPageUrl,
    required String confluenceUsername,
    required String confluenceAccessToken,
  }) async {
    // 1. Lấy header (Bearer token + x-jarvis-guid)
    final headers = await getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    // 2. Build URI
    final uri = Uri.parse(
      '$knowledgeUrl/kb-core/v1/knowledge/$knowledgeId/confluence',
    );

    // 3. Chuẩn bị body JSON
    final body = jsonEncode({
      'unitName': unitName,
      'wikiPageUrl': wikiPageUrl,
      'confluenceUsername': confluenceUsername,
      'confluenceAccessToken': confluenceAccessToken,
    });

    // 4. Gửi POST
    final response = await http.post(uri, headers: headers, body: body);

    // 5. Xử lý kết quả
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to upload knowledge from Confluence: '
        '[${response.statusCode}] ${response.reasonPhrase}',
      );
    }
  }

  /// CÁC API SUBCRIPTION ///
  // Lấy thông tin usage của subscription hiện tại
  Future<Map<String, dynamic>> getSubscriptionUsage() async {
    // Build URL
    final uri = Uri.parse('$jarvisUrl/api/v1/subscriptions/me');
    // Gọi GET với header đã auth
    final response = await authenticatedGet(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to fetch subscription usage: '
        '[${response.statusCode}] ${response.reasonPhrase}\n'
        'Body: ${response.body}',
      );
    }
  }

  // Gửi request để subscribe (mở gói dịch vụ)
  Future<Map<String, dynamic>> subscribe() async {
    // Build URL
    final uri = Uri.parse('$jarvisUrl/api/v1/subscriptions/subscribe');
    // Gọi GET với header đã auth
    final response = await authenticatedGet(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to subscribe: '
        '[${response.statusCode}] ${response.reasonPhrase}\n'
        'Body: ${response.body}',
      );
    }
  }
}

final apiBaseInstance = ApiBase();
