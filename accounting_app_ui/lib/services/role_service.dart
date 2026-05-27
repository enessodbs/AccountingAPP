import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class RoleService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> getRoles() async {
    final response = await http.get(
      Uri.parse(ApiConfig.roles),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Roller yüklenemedi: ${response.statusCode}');
    }
  }

  Future<void> addRole(String roleName, List<String> permissions) async {
    final response = await http.post(
      Uri.parse(ApiConfig.roles),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': roleName,
        'permissions': permissions,
        'Permissions': permissions,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Rol eklenirken hata oluştu: ${response.statusCode}');
    }
  }

  Future<void> updateRole(String roleId, String roleName, List<String> permissions) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.roles}/$roleId'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': roleName,
        'permissions': permissions,
        'Permissions': permissions,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Rol güncellenirken hata oluştu: ${response.statusCode}');
    }
  }

  Future<void> deleteRole(String roleId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.roles}/$roleId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Rol silinirken hata oluştu: ${response.statusCode}');
    }
  }
}
