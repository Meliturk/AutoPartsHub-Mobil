import '../models/auth.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<AuthSession> login(String email, String password) async {
    final data = await _api.postMap('/api/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthSession.fromJson(data);
  }

  Future<AuthActionResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final data = await _api.postMap('/api/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    return AuthActionResult.fromJson(data);
  }

  Future<AuthActionResult> confirmEmail(String email, String token) async {
    final data = await _api.postMap('/api/auth/confirm', {
      'email': email,
      'token': token,
    });
    return AuthActionResult.fromJson(data);
  }

  Future<AuthActionResult> resendConfirm(String email) async {
    final data = await _api.postMap('/api/auth/resend-confirm', {
      'email': email,
    });
    return AuthActionResult.fromJson(data);
  }

  Future<AuthActionResult> forgotPassword(String email) async {
    final data = await _api.postMap('/api/auth/forgot', {
      'email': email,
    });
    return AuthActionResult.fromJson(data);
  }

  Future<AuthActionResult> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    final data = await _api.postMap('/api/auth/reset', {
      'email': email,
      'token': token,
      'password': password,
    });
    return AuthActionResult.fromJson(data);
  }

  Future<AuthSession> me(String token) async {
    final data = await _api.getMap('/api/auth/me', token: token);
    return AuthSession.fromJson(data);
  }

  Future<AuthSession> updateProfile({
    required String fullName,
    required String email,
    required String token,
  }) async {
    final data = await _api.putMap('/api/auth/update-profile', {
      'fullName': fullName,
      'email': email,
    }, token: token);
    return AuthSession.fromJson(data);
  }

  Future<AuthActionResult> sellerApply({
    required String fullName,
    required String email,
    required String password,
    required String companyName,
    required String phone,
    required String address,
    String? taxNumber,
    String? note,
  }) async {
    final data = await _api.postMap('/api/seller/apply', {
      'fullName': fullName,
      'email': email,
      'password': password,
      'companyName': companyName,
      'phone': phone,
      'address': address,
      if (taxNumber != null) 'taxNumber': taxNumber,
      if (note != null) 'note': note,
    });
    return AuthActionResult.fromJson(data);
  }
}
