import 'package:flutter/foundation.dart';

import '../models/auth.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthStore extends ChangeNotifier {
  AuthStore(this._service);

  final AuthService _service;

  AuthSession? _session;
  bool _busy = false;
  String? _error;

  AuthSession? get session => _session;
  bool get isBusy => _busy;
  String? get error => _error;
  bool get isAuthenticated => _session != null;

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<AuthSession?> login(String email, String password) async {
    _setBusy(true);
    _setError(null);
    try {
      final session = await _service.login(email, password);
      _session = session;
      return session;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthActionResult?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    _setError(null);
    try {
      return await _service.register(
        fullName: fullName,
        email: email,
        password: password,
      );
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthActionResult?> confirmEmail(String email, String token) async {
    _setBusy(true);
    _setError(null);
    try {
      return await _service.confirmEmail(email, token);
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthActionResult?> resendConfirm(String email) async {
    _setBusy(true);
    _setError(null);
    try {
      return await _service.resendConfirm(email);
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthActionResult?> forgotPassword(String email) async {
    _setBusy(true);
    _setError(null);
    try {
      return await _service.forgotPassword(email);
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthActionResult?> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    _setBusy(true);
    _setError(null);
    try {
      return await _service.resetPassword(
        email: email,
        token: token,
        password: password,
      );
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> refresh() async {
    if (_session == null) return;
    _setBusy(true);
    _setError(null);
    try {
      _session = await _service.me(_session!.token);
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthSession?> updateProfile({
    required String fullName,
    required String email,
  }) async {
    if (_session == null) return null;
    _setBusy(true);
    _setError(null);
    try {
      final session = await _service.updateProfile(
        fullName: fullName,
        email: email,
        token: _session!.token,
      );
      _session = session;
      return session;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setBusy(false);
    }
  }

  void logout() {
    _session = null;
    notifyListeners();
  }
}
