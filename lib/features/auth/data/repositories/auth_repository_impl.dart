import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

part 'auth_repository_impl.g.dart';

@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageServiceProvider),
  );
}

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._remoteDataSource, this._storage);

  @override
  Future<Either<Failure, User>> login({required String provider, required String token}) async {
    try {
      final response = await _remoteDataSource.login(provider, token);
      
      await _storage.write(key: StorageConstants.accessToken, value: response.accessToken);
      await _storage.write(key: StorageConstants.refreshToken, value: response.refreshToken);
      
      return right(response.user);
    } on DioException catch (e) {
      return left(ServerFailure(e.message ?? 'Login failed'));
    } catch (e) {
      return left(const ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, User>> saveTokens(String accessToken, String refreshToken) async {
    try {
      // Store tokens
      await _storage.write(key: StorageConstants.accessToken, value: accessToken);
      await _storage.write(key: StorageConstants.refreshToken, value: refreshToken);
      
      // Fetch user profile from server using the access token
      // TODO: Implement getUserProfile API call
      // For now, return a mock user
      final user = User(
        id: 'temp-id',
        nickname: 'User',
        email: 'user@example.com',
        notificationSetting: true,
        isSubscriber: false,
        isDeactivated: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return right(user);
    } catch (e) {
      return left(CacheFailure('Failed to save tokens: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _storage.deleteAll();
      return right(null);
    } catch (e) {
      return left(const CacheFailure('Logout failed'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final accessToken = await _storage.read(key: StorageConstants.accessToken);
      
      if (accessToken == null) {
        return left(const CacheFailure('No access token found'));
      }
      
      // TODO: Implement getUserProfile API call
      // For now, return a mock user if token exists
      final user = User(
        id: 'temp-id',
        nickname: 'User',
        email: 'user@example.com',
        notificationSetting: true,
        isSubscriber: false,
        isDeactivated: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return right(user);
    } catch (e) {
      return left(CacheFailure('Failed to get current user: $e'));
    }
  }
}
