import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class CurrencyService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> getCurrencies() async {
    final response = await http.get(
      Uri.parse(ApiConfig.currencies),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Dövizler yüklenemedi: ${response.statusCode}');
    }
  }

  Future<void> addCurrency(String code, String symbol) async {
    final response = await http.post(
      Uri.parse(ApiConfig.currencies),
      headers: await _getHeaders(),
      body: jsonEncode({
        'code': code,
        'symbol': symbol,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Döviz eklenirken hata oluştu: ${response.statusCode}');
    }
  }

  Future<void> deleteCurrency(int currencyId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.currencies}/$currencyId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Döviz silinirken hata oluştu: ${response.statusCode}');
    }
  }
}
