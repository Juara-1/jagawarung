import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class TokenService {
  static const _storage = FlutterSecureStorage();
  
  // Keys
  static const String _accessTokenKey = 'supabase_access_token';
  static const String _refreshTokenKey = 'supabase_refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';


  static Future<void> saveTokens({
    required String accessToken,
    required String? refreshToken,
    required String userId,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      if (refreshToken != null) 
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userEmailKey, value: email),
    ]);
    
  }


  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }


  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }


  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }


  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }


  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  
  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }


  static Future<Map<String, String>> getAllData() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final userId = await getUserId();
    final email = await getUserEmail();

    return {
      'accessToken': accessToken ?? 'null',
      'refreshToken': refreshToken ?? 'null',
      'userId': userId ?? 'null',
      'email': email ?? 'null',
    };
  }
}


