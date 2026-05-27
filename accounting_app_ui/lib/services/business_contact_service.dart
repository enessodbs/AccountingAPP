import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class BusinessContactService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getContacts() async {
    final response = await http.get(
      Uri.parse(ApiConfig.businessContacts),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('İş ortakları yüklenemedi: ${response.statusCode}');
    }
  }

  Future<void> deleteContact(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.businessContacts}/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('İş ortağı silinirken bir hata oluştu');
    }
  }
}
