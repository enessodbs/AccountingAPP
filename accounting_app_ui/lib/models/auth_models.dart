class LoginResponse {
  final String token;
  final String username;
  final DateTime expiration;
  final List<String> roles;
  final List<String> permissions;

  LoginResponse({
    required this.token,
    required this.username,
    required this.expiration,
    required this.roles,
    required this.permissions,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      username: json['username'],
      expiration: DateTime.parse(json['expiration']),
      roles: List<String>.from(json['roles']),
      permissions: List<String>.from(json['permissions'] ?? json['Permissions'] ?? []),
    );
  }
}
