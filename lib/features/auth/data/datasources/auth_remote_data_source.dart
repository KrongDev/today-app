import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../dtos/auth_response.dart';

part 'auth_remote_data_source.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
}

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<AuthResponse> login(String provider, String token) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'provider': provider,
        'token': token,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  // TODO: Add refresh token method here if not handled solely by interceptor
}
