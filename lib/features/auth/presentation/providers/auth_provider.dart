import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<User?> build() {
    return null; // Initially null (not logged in)
  }

  Future<void> login(String provider, String token) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(authRepositoryProvider);
    final useCase = LoginUseCase(repository);
    
    final result = await useCase.execute(provider: provider, token: token);
    
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
