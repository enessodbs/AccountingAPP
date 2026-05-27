import 'dart:convert';

void main() {
  final selectedPermissions = ['Personeller', 'Faturalar'];
  final body = jsonEncode({
    'name': 'Test Role',
    'permissions': selectedPermissions,
  });
  print(body);
}
