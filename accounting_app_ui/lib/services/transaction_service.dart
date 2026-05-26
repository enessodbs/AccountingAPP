import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/transaction.dart';
import 'auth_service.dart';

class TransactionService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<Transaction>> getTransactions({int? type}) async {
    try {
      var url = ApiConfig.transactions;
      if (type != null) url += '?type=$type';

      final response = await http.get(Uri.parse(url), headers: await _headers());

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Transaction.fromJson(item)).toList();
      } else {
        throw Exception('İşlemler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> createTransaction(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.transactions),
        headers: await _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('İşlem oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.transactions}/$id'),
        headers: await _headers(),
      );

      if (response.statusCode != 204) {
        throw Exception('İşlem silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// İş ortaklarını getir (dropdown için)
  Future<List<BusinessContactItem>> getBusinessContacts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.businessContacts),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => BusinessContactItem.fromJson(item)).toList();
      } else {
        throw Exception('İş ortakları yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// Yeni İş Ortağı (Müşteri vb.) Ekle
  Future<BusinessContactItem> createBusinessContact(String name, int type) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.businessContacts),
        headers: await _headers(),
        body: jsonEncode({
          'name': name,
          'type': type,
          'taxNumber': '',
          'taxOffice': '',
          'email': '',
          'phone': '',
          'address': '',
        }),
      );

      if (response.statusCode == 201) {
        return BusinessContactItem.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('İş ortağı oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }
}

/// İş ortağı lookup modeli
class BusinessContactItem {
  final String id;
  final String name;
  final int type; // 1: Customer, 2: Supplier, 3: Both

  BusinessContactItem({required this.id, required this.name, required this.type});

  factory BusinessContactItem.fromJson(Map<String, dynamic> json) {
    return BusinessContactItem(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? 1,
    );
  }

  String get typeText {
    switch (type) {
      case 1: return 'Müşteri';
      case 2: return 'Tedarikçi';
      case 3: return 'Müşteri/Tedarikçi';
      default: return '';
    }
  }
}
