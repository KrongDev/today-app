import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<User?> build() async {
    // Try to load user from stored tokens
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.getCurrentUser();
    
    return result.fold(
      (failure) => null,
      (user) => user,
    );
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.saveTokens(accessToken, refreshToken);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncValue.data(null);
  }
}
