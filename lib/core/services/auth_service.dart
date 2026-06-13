import 'package:tubes_ppb_app/core/network/api_service.dart';
import 'package:tubes_ppb_app/models/user_model.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Synchronize Firebase authenticated credentials with the Laravel backend.
  /// Returns a map with 'user' (UserModel) and 'token' (String).
  Future<Map<String, dynamic>> firebaseSync({
    required String firebaseUid,
    required String name,
    required String email,
    String? avatarUrl,
    String? phone,
    String? role, // 'agent' or 'traveler'
  }) async {
    final response = await _apiService.post('/auth/firebase-sync', data: {
      'firebase_uid': firebaseUid,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'phone': phone,
      'role': role,
    });

    final data = response.data;
    final user = UserModel.fromJson(data['user']);
    final token = data['token'] as String;

    return {
      'user': user,
      'token': token,
    };
  }

  /// Fetch the currently authenticated user profile from backend
  Future<UserModel> getProfile() async {
    final response = await _apiService.get('/auth/me');
    return UserModel.fromJson(response.data['user']);
  }

  /// Revoke current access token on the backend
  Future<void> logout() async {
    await _apiService.post('/auth/logout');
  }
}
