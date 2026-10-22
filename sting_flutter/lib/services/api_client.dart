import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

/// Points at the Sting backend (see /sting_backend in the project root
/// you unzipped this alongside).
///
/// - Android emulator: 10.0.2.2 is the emulator's alias for your PC's
///   localhost — this is the default below.
/// - Physical phone on the same Wi-Fi as your PC: replace with your PC's
///   local IP, e.g. "http://192.168.1.23:4000/api" (find it with
///   `ipconfig` in PowerShell).
/// - iOS simulator: "http://localhost:4000/api" works directly.
class ApiConfig {
  // TODO: replace with your PC's local IP (find it with `ipconfig` in
  // PowerShell, look for "IPv4 Address" under your active Wi-Fi adapter).
  // Your phone and PC must be on the same Wi-Fi network.
  // Example: "http://192.168.1.23:4000/api"
static String baseUrl = "http://localhost:4000/api";
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiClient {
  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('sting_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sting_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sting_token');
  }

  bool get isLoggedIn => _token != null;

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        if (_token != null) "Authorization": "Bearer $_token",
      };

  Uri _u(String path) => Uri.parse("${ApiConfig.baseUrl}$path");

  dynamic _handle(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(body["error"] ?? "Request failed (${res.statusCode})", statusCode: res.statusCode);
  }

  // ---------------- Auth ----------------

  Future<Map<String, dynamic>> register({String? email, String? phone, required String password}) async {
    final res = await http.post(_u("/auth/register"),
        headers: _headers, body: jsonEncode({"email": email, "phone": phone, "password": password}));
    return _handle(res);
  }

  Future<String> verifyOtp({required String contact, required String code}) async {
    final res = await http.post(_u("/auth/verify-otp"),
        headers: _headers, body: jsonEncode({"contact": contact, "code": code}));
    final data = _handle(res);
    await _saveToken(data["token"]);
    return data["token"];
  }

  Future<String> login({required String emailOrUsername, required String password}) async {
    final res = await http.post(_u("/auth/login"),
        headers: _headers, body: jsonEncode({"emailOrUsername": emailOrUsername, "password": password}));
    final data = _handle(res);
    await _saveToken(data["token"]);
    return data["token"];
  }

  Future<void> forgotPassword(String email) async {
    final res = await http.post(_u("/auth/forgot-password"), headers: _headers, body: jsonEncode({"email": email}));
    _handle(res);
  }

  Future<bool> checkUsername(String username) async {
    final res = await http.get(_u("/auth/check-username/$username"));
    final data = _handle(res);
    return data["available"] == true;
  }

  // ---------------- Users ----------------

  Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(_u("/users/me"), headers: _headers);
    return _handle(res);
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> fields) async {
    final res = await http.put(_u("/users/me"), headers: _headers, body: jsonEncode(fields));
    return _handle(res);
  }

  Future<Map<String, dynamic>> getUser(String username) async {
    final res = await http.get(_u("/users/$username"));
    return _handle(res);
  }

  // ---------------- Follow ----------------

  Future<void> follow(String username) async {
    final res = await http.post(_u("/follow/$username"), headers: _headers);
    _handle(res);
  }

  Future<void> unfollow(String username) async {
    final res = await http.delete(_u("/follow/$username"), headers: _headers);
    _handle(res);
  }

  Future<List<dynamic>> following(String username) async {
    final res = await http.get(_u("/follow/$username/following"));
    return _handle(res);
  }

  Future<List<dynamic>> followers(String username) async {
    final res = await http.get(_u("/follow/$username/followers"));
    return _handle(res);
  }

  Future<List<dynamic>> suggested() async {
    final res = await http.get(_u("/follow/suggested/for-me"), headers: _headers);
    return _handle(res);
  }

  // ---------------- Tasks ----------------

  Future<Map<String, dynamic>> todaysTask() async {
    final res = await http.get(_u("/tasks/today"));
    return _handle(res);
  }

  // ---------------- Posts & Feed ----------------

  Future<Map<String, dynamic>> createPost({
    required String taskLabel,
    required String caption,
    required bool verifiedLive,
    required DateTime capturedAt,
    String? imagePath,
  }) async {
    final request = http.MultipartRequest("POST", _u("/posts"));
    request.headers.addAll({if (_token != null) "Authorization": "Bearer $_token"});
    request.fields["taskLabel"] = taskLabel;
    request.fields["caption"] = caption;
    request.fields["verifiedLive"] = verifiedLive.toString();
    request.fields["capturedAt"] = capturedAt.toIso8601String();
    if (imagePath != null && File(imagePath).existsSync()) {
            request.files.add(await http.MultipartFile.fromPath(
        "image",
        imagePath,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  Future<List<dynamic>> myPosts() async {
    final res = await http.get(_u("/posts/me"), headers: _headers);
    return _handle(res);
  }

  Future<Map<String, dynamic>> feed() async {
    final res = await http.get(_u("/feed"), headers: _headers);
    return _handle(res);
  }

  Future<Map<String, dynamic>> verify(int postId, String reaction) async {
    final res = await http.post(_u("/posts/$postId/verify"),
        headers: _headers, body: jsonEncode({"reaction": reaction}));
    return _handle(res);
  }

  Future<Map<String, dynamic>> unverify(int postId) async {
    final res = await http.delete(_u("/posts/$postId/verify"), headers: _headers);
    return _handle(res);
  }

  Future<Map<String, dynamic>> useFreezePass() async {
    final res = await http.post(_u("/users/me/freeze"), headers: _headers);
    return _handle(res);
  }

  Future<Map<String, dynamic>> getRecap() async {
    final res = await http.get(_u("/users/me/recap"), headers: _headers);
    return _handle(res);
  }

  Future<int> like(int postId) async {
    final res = await http.post(_u("/posts/$postId/like"), headers: _headers);
    final data = _handle(res);
    return data["likes"];
  }

  Future<int> unlike(int postId) async {
    final res = await http.delete(_u("/posts/$postId/like"), headers: _headers);
    final data = _handle(res);
    return data["likes"];
  }

  // ---------------- Leaderboard & Challenges ----------------

  Future<List<dynamic>> getLeaderboardStreaks() async {
    final res = await http.get(_u("/leaderboard/streaks"));
    return _handle(res);
  }

  Future<List<dynamic>> getLeaderboardScores() async {
    final res = await http.get(_u("/leaderboard/scores"));
    return _handle(res);
  }

  Future<List<dynamic>> getLeaderboardFriends() async {
    final res = await http.get(_u("/leaderboard/friends"), headers: _headers);
    return _handle(res);
  }

  Future<Map<String, dynamic>> sendFriendChallenge(String friendUsername, String taskLabel) async {
    final res = await http.post(
      _u("/challenges/friend"),
      headers: _headers,
      body: jsonEncode({"friendUsername": friendUsername, "taskLabel": taskLabel}),
    );
    return _handle(res);
  }
}

