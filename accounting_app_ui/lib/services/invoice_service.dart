import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/invoice.dart';
import 'auth_service.dart';

class InvoiceService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Faturaları getir. [type]: 1=Sales, 2=Purchase. [status]: 1=Pending, 2=Paid, 5=Issued, 6=ToBeIssued
  /// [fromDate]/[toDate]: Fatura kesim tarihi (IssueDate) aralığı, uçlar dahil.
  /// [excludeCancelled]: true ise iptal (status 3) faturalar dönmez; kâr/zarar ile uyum için kullanın.
  Future<List<Invoice>> getInvoices({
    int? type,
    int? status,
    DateTime? fromDate,
    DateTime? toDate,
    bool excludeCancelled = false,
  }) async {
    try {
      final q = <String, String>{};
      if (type != null) q['type'] = '$type';
      if (status != null) q['status'] = '$status';
      if (fromDate != null) q['fromDate'] = _isoDate(fromDate);
      if (toDate != null) q['toDate'] = _isoDate(toDate);
      if (excludeCancelled) q['excludeCancelled'] = 'true';
      final uri = Uri.parse(ApiConfig.invoices).replace(
        queryParameters: q.isEmpty ? null : q,
      );

      final response = await http.get(uri, headers: await _headers());

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Invoice.fromJson(item)).toList();
      } else {
        throw Exception('Faturalar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<InvoiceDetail> getInvoiceDetail(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.invoices}/$id'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return InvoiceDetail.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Fatura detayı yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// Yeni fatura oluştur
  Future<void> createInvoice(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.invoices),
        headers: await _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Fatura oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// Fatura sil (soft delete)
  Future<void> deleteInvoice(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.invoices}/$id'),
        headers: await _headers(),
      );

      if (response.statusCode != 204) {
        throw Exception('Fatura silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// Fatura durumunu güncelle
  Future<void> updateInvoiceStatus(String id, int status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.invoices}/$id/status'),
        headers: await _headers(),
        body: jsonEncode(status),
      );

      if (response.statusCode != 204) {
        throw Exception('Durum güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }
}
