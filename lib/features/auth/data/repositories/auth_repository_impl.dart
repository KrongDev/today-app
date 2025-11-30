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

// We need a provider for the service wrapper, let's create it quickly in secure_storage.dart or here.
// For now, let's assume we update secure_storage.dart to provide the service.

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
      // Save User ID or Profile locally if needed
      
      return right(response.user);
    } on DioException catch (e) {
      return left(ServerFailure(e.message ?? 'Login failed'));
    } catch (e) {
      return left(const Failure('Unexpected error'));
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
    // TODO: Implement get current user from local storage or API
    return left(const Failure('Not implemented'));
  }
}
