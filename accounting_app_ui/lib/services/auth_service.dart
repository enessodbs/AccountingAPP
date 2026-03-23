import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/auth_models.dart';

class AuthService {
  Future<LoginResponse?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.auth}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        // Save token to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', loginResponse.token);
        await prefs.setString('username', loginResponse.username);
        await prefs.setStringList('roles', loginResponse.roles);

        return loginResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Kullanıcı adı veya şifre hatalı.');
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Kullanıcı adı')) {
        rethrow;
      }
      throw Exception('Giriş başarısız: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('username');
    await prefs.remove('roles');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<List<String>> getRoles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('roles') ?? [];
  }

  // ─── Remember Me ───
  Future<void> saveRememberedCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remembered_username', username);
    await prefs.setString('remembered_password', password);
    await prefs.setBool('remember_me', true);
  }

  Future<void> clearRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remembered_username');
    await prefs.remove('remembered_password');
    await prefs.setBool('remember_me', false);
  }

  Future<Map<String, dynamic>> getRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'remember_me': prefs.getBool('remember_me') ?? false,
      'username': prefs.getString('remembered_username') ?? '',
      'password': prefs.getString('remembered_password') ?? '',
    };
  }

  // ─── Forgot Password ───
  Future<String> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.auth}/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Şifre sıfırlama bağlantısı gönderildi.';
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'İşlem başarısız oldu.';
      }
    } catch (_) {
      return 'Sunucuya bağlanılamadı. Lütfen tekrar deneyin.';
    }
  }
}

