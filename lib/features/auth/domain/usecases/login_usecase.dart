import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

part 'login_usecase.g.dart';

class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, User>> execute({required String provider, required String token}) {
    return _repository.login(provider: provider, token: token);
  }
}

// We will define the provider in the data layer or a DI module, 
// but for simplicity with riverpod_generator, we can define it here if we had the repo provider.
// However, since Repo implementation is in Data layer, we'll wire it up in the presentation layer or a shared provider file.
