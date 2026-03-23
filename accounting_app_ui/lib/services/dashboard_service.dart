import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/dashboard_models.dart';
import 'auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<DashboardSummary> getSummary() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.dashboard}/summary'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return DashboardSummary.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Dashboard verisi yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<MonthlyChartData> getMonthlyChart() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.dashboard}/monthly-chart'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return MonthlyChartData.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Grafik verisi yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }
}
