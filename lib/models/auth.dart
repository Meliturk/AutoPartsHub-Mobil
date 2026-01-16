import 'json_utils.dart';

class AuthSession {
  const AuthSession({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.token,
  });

  final int id;
  final String fullName;
  final String email;
  final String role;
  final String token;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      id: jsonToInt(json['id']),
      fullName: jsonToString(json['fullName']),
      email: jsonToString(json['email']),
      role: jsonToString(json['role']),
      token: jsonToString(json['token']),
    );
  }
}

class AuthActionResult {
  const AuthActionResult({
    required this.message,
    this.confirmLink,
    this.confirmToken,
    this.resetLink,
    this.resetToken,
  });

  final String message;
  final String? confirmLink;
  final String? confirmToken;
  final String? resetLink;
  final String? resetToken;

  factory AuthActionResult.fromJson(Map<String, dynamic> json) {
    return AuthActionResult(
      message: json['message']?.toString() ?? 'OK',
      confirmLink: json['confirmLink']?.toString(),
      confirmToken: json['confirmToken']?.toString(),
      resetLink: json['resetLink']?.toString(),
      resetToken: json['resetToken']?.toString(),
    );
  }
}
