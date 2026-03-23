class LoginResponse {
  final String token;
  final String username;
  final DateTime expiration;
  final List<String> roles;

  LoginResponse({
    required this.token,
    required this.username,
    required this.expiration,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      username: json['username'],
      expiration: DateTime.parse(json['expiration']),
      roles: List<String>.from(json['roles']),
    );
  }
}
