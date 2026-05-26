import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/crm_models.dart';
import 'auth_service.dart';

class CrmService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── Leads ───

  Future<List<LeadModel>> getLeads({int? status, int? source, String? search}) async {
    try {
      var url = ApiConfig.leads;
      final params = <String>[];
      if (status != null) params.add('status=$status');
      if (source != null) params.add('source=$source');
      if (search != null && search.isNotEmpty) params.add('search=$search');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(Uri.parse(url), headers: await _headers());

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => LeadModel.fromJson(item)).toList();
      } else {
        throw Exception('Lead\'ler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<Map<String, dynamic>> getLeadDetail(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.leads}/$id'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lead detayı yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> createLead(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.leads),
        headers: await _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Lead oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> updateLead(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.leads}/$id'),
        headers: await _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Lead güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> updateLeadStatus(String id, int status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.leads}/$id/status'),
        headers: await _headers(),
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Lead durumu güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> convertLead(String id) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.leads}/$id/convert'),
        headers: await _headers(),
        body: jsonEncode({
          'createOpportunity': false,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Lead dönüştürülemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> deleteLead(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.leads}/$id'),
        headers: await _headers(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Lead silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  // ─── Pipeline Board ───

  Future<List<PipelineBoardColumn>> getPipelineBoard() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.opportunities}/board'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => PipelineBoardColumn.fromJson(item)).toList();
      } else {
        throw Exception('Pipeline board yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  // ─── Opportunities ───

  Future<List<OpportunityModel>> getOpportunities({int? stageId, String? search}) async {
    try {
      var url = ApiConfig.opportunities;
      final params = <String>[];
      if (stageId != null) params.add('stageId=$stageId');
      if (search != null && search.isNotEmpty) params.add('search=$search');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(Uri.parse(url), headers: await _headers());

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => OpportunityModel.fromJson(item)).toList();
      } else {
        throw Exception('Fırsatlar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> createOpportunity(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.opportunities),
        headers: await _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Fırsat oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> updateOpportunity(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.opportunities}/$id'),
        headers: await _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Fırsat güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> moveOpportunity(String id, int stageId, {int? probability}) async {
    try {
      final body = <String, dynamic>{'stageId': stageId};
      if (probability != null) body['probability'] = probability;

      final response = await http.put(
        Uri.parse('${ApiConfig.opportunities}/$id/move'),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Fırsat taşınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> closeOpportunity(String id, bool isWon, {String? lostReason}) async {
    try {
      final body = <String, dynamic>{'isWon': isWon};
      if (lostReason != null) body['lostReason'] = lostReason;

      final response = await http.put(
        Uri.parse('${ApiConfig.opportunities}/$id/close'),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Fırsat kapatılamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<void> deleteOpportunity(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.opportunities}/$id'),
        headers: await _headers(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Fırsat silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  // ─── Pipeline Stages ───

  Future<List<PipelineStageModel>> getPipelineStages() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.pipelineStages),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => PipelineStageModel.fromJson(item)).toList();
      } else {
        throw Exception('Pipeline aşamaları yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }
}
