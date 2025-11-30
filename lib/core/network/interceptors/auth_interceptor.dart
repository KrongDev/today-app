import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/api_constants.dart';
import '../../logging/logger.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  List<void Function()> _pendingRequests = [];
  
  AuthInterceptor(this._storage, this._dio);

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
      Logger.d('401 Unauthorized - Attempting token refresh');
      
      // If already refreshing, queue this request
      if (_isRefreshing) {
        await _waitForRefresh();
        return _retry(err.requestOptions, handler);
      }
      
      _isRefreshing = true;
      
      try {
        final refreshToken = await _storage.read(key: StorageConstants.refreshToken);
        
        if (refreshToken == null) {
          Logger.e('No refresh token available');
          _isRefreshing = false;
          return handler.next(err);
        }
        
        // Call refresh endpoint
        final response = await _dio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
        
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        
        // Save new tokens
        await _storage.write(key: StorageConstants.accessToken, value: newAccessToken);
        await _storage.write(key: StorageConstants.refreshToken, value: newRefreshToken);
        
        Logger.d('Token refreshed successfully');
        
        _isRefreshing = false;
        _processPendingRequests();
        
        // Retry original request
        return _retry(err.requestOptions, handler);
        
      } catch (e) {
        Logger.e('Token refresh failed: $e');
        _isRefreshing = false;
        _clearPendingRequests();
        
        // Clear tokens on refresh failure
        await _storage.delete(key: StorageConstants.accessToken);
        await _storage.delete(key: StorageConstants.refreshToken);
        
        return handler.next(err);
      }
    }
    
    handler.next(err);
  }
  
  Future<void> _waitForRefresh() async {
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
  
  void _processPendingRequests() {
    for (final request in _pendingRequests) {
      request();
    }
    _pendingRequests.clear();
  }
  
  void _clearPendingRequests() {
    _pendingRequests.clear();
  }
  
  Future<void> _retry(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final token = await _storage.read(key: StorageConstants.accessToken);
      requestOptions.headers['Authorization'] = 'Bearer $token';
      
      final response = await _dio.fetch(requestOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.reject(
        DioException(requestOptions: requestOptions, error: e),
      );
    }
  }
}
