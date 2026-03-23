import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/employee.dart';
import 'auth_service.dart';

/// API'den lookup verilerini (Departman, Pozisyon, Kategori) çekmek için servis
class LookupService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<List<DepartmentLookup>> getDepartments() async {
    final response = await http.get(Uri.parse(ApiConfig.departments), headers: await _headers());
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).map((e) => DepartmentLookup.fromJson(e)).toList();
    }
    throw Exception('Departmanlar yüklenemedi: ${response.statusCode}');
  }

  Future<List<PositionLookup>> getPositions({int? departmentId}) async {
    var url = ApiConfig.positions;
    if (departmentId != null) url += '?departmentId=$departmentId';
    final response = await http.get(Uri.parse(url), headers: await _headers());
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).map((e) => PositionLookup.fromJson(e)).toList();
    }
    throw Exception('Pozisyonlar yüklenemedi: ${response.statusCode}');
  }

  Future<List<CategoryLookup>> getCategories() async {
    final response = await http.get(Uri.parse(ApiConfig.categories), headers: await _headers());
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).map((e) => CategoryLookup.fromJson(e)).toList();
    }
    throw Exception('Kategoriler yüklenemedi: ${response.statusCode}');
  }
}
