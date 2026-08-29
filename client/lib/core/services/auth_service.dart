import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'storage_service.dart';
import '../api/api_client.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});

class AuthService {
  final ApiClient _apiClient;
  
  AuthService(this._apiClient);

  bool get isAuthenticated {
    final token = StorageService.getUserId();
    return token != null && token.isNotEmpty;
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.login({
        'email': email,
        'password': password,
      });
      
      if (response['access_token'] != null) {
        await StorageService.saveAuthTokens(
          response['access_token'],
          response['refresh_token'] ?? '',
        );
        
        final decodedToken = JwtDecoder.decode(response['access_token']);
        await StorageService.saveUserId(decodedToken['sub']);
        await StorageService.saveUserRole(decodedToken['role'] ?? 'student');
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAuthTokens();
    await StorageService.remove('user_id');
    await StorageService.remove('user_role');
  }

  Future<String?> getAccessToken() async {
    final token = await StorageService.getAccessToken();
    
    if (token != null && JwtDecoder.isExpired(token)) {
      // Token expired, try to refresh
      return await refreshToken();
    }
    
    return token;
  }

  Future<String?> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return null;
      
      final response = await _apiClient.refreshToken({
        'refresh_token': refreshToken,
      });
      
      if (response['access_token'] != null) {
        await StorageService.saveAuthTokens(
          response['access_token'],
          response['refresh_token'] ?? refreshToken,
        );
        return response['access_token'];
      }
      return null;
    } catch (e) {
      await logout();
      return null;
    }
  }
}
