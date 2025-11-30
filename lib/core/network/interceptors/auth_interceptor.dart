import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/api_constants.dart';
import '../../logging/logger.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  // Access token should be kept in memory for security, but for simplicity in this phase we might read from storage or a provider.
  // In a real app, we'd inject a TokenProvider.
  
  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: StorageConstants.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      Logger.d('401 Unauthorized - Attempting refresh');
      // TODO: Implement Token Refresh Logic
      // 1. Lock interceptor
      // 2. Get Refresh Token
      // 3. Call /auth/refresh
      // 4. Save new tokens
      // 5. Retry original request
    }
    handler.next(err);
  }
}
