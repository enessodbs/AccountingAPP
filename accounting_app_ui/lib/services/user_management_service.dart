import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class UserManagementService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Tüm kullanıcıları listele
  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.userManagement}'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Kullanıcılar yüklenemedi: ${response.statusCode}');
  }

  /// Tüm rolleri listele
  Future<List<Map<String, dynamic>>> getRoles() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.userManagement}/roles'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Roller yüklenemedi: ${response.statusCode}');
  }

  /// Kullanıcı rollerini güncelle
  Future<bool> updateUserRoles(String userId, List<String> roleNames) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.userManagement}/$userId/roles'),
      headers: await _authHeaders(),
      body: jsonEncode({'roleNames': roleNames}),
    );
    return response.statusCode == 200;
  }

  /// Kullanıcı sil (soft delete)
  Future<bool> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.userManagement}/$userId'),
      headers: await _authHeaders(),
    );
    return response.statusCode == 200;
  }

  /// Yeni kullanıcı oluştur
  Future<Map<String, dynamic>> createUser({
    required String username,
    required String email,
    required String password,
    required String roleName,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.auth}/register'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'roleName': roleName,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Kullanıcı oluşturulamadı');
  }

  /// Kullanıcı bilgilerini güncelle (username, email)
  Future<String> updateUserInfo(String userId, {String? username, String? email}) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.userManagement}/$userId'),
      headers: await _authHeaders(),
      body: jsonEncode({
        if (username != null) 'username': username,
        if (email != null) 'email': email,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Güncellendi';
    }
    throw Exception(data['message'] ?? 'Güncelleme başarısız');
  }

  /// Kullanıcı şifresini sıfırla
  Future<String> resetPassword(String userId, String newPassword) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.userManagement}/$userId/reset-password'),
      headers: await _authHeaders(),
      body: jsonEncode({'newPassword': newPassword}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Şifre sıfırlandı';
    }
    throw Exception(data['message'] ?? 'Şifre sıfırlama başarısız');
  }
}

