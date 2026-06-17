import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/user_profile.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider(this.api);

  ApiClient api;
  UserProfile? user;
  bool loading = false;
  String? error;

  bool get isAuthenticated => api.token != null && user != null;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    api.token = prefs.getString('token');
    if (api.token == null) return;
    await refreshProfile();
  }

  Future<void> login(String email, String password) async {
    await _authenticate('/auth/login', {'email': email, 'password': password});
  }

  Future<void> register(
      String name, String username, String email, String password) async {
    await _authenticate('/auth/register', {
      'name': name,
      'username': username,
      'email': email,
      'password': password
    });
  }

  Future<void> _authenticate(String path, Map<String, dynamic> body) async {
    await _run(() async {
      final response = await api.post(path, body);
      api.token = response['token'] as String;
      user = UserProfile.fromJson(response['user'] as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', api.token!);
    });
  }

  Future<void> refreshProfile() async {
    await _run(() async {
      user = UserProfile.fromJson(await api.get('/me'));
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    api.token = null;
    user = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() task) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await task();
    } catch (exception) {
      error = exception.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
