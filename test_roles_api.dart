// ignore_for_file: uri_does_not_exist
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'http://localhost:5188/api';
  
  // Login to get token
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': 'admin', 'password': '[YOUR_TEST_PASSWORD]'}),
  );
  
  if (loginRes.statusCode != 200) {
    print('Login failed: ${loginRes.statusCode} ${loginRes.body}');
    return;
  }
  
  final token = jsonDecode(loginRes.body)['token'];
  final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  
  // Get Roles
  final rolesRes = await http.get(Uri.parse('$baseUrl/Roles'), headers: headers);
  final roles = jsonDecode(rolesRes.body) as List;
  print('Roles: $roles');
  
  if (roles.isEmpty) return;
  final roleId = roles[0]['id'];
  
  // Update Role
  final updateRes = await http.put(
    Uri.parse('$baseUrl/Roles/$roleId'),
    headers: headers,
    body: jsonEncode({'name': roles[0]['name'], 'permissions': ['Personeller', 'Raporlar']}),
  );
  
  print('Update status: ${updateRes.statusCode} ${updateRes.body}');
  
  // Get Roles again
  final rolesRes2 = await http.get(Uri.parse('$baseUrl/Roles'), headers: headers);
  print('Roles after update: ${jsonDecode(rolesRes2.body)}');
}
