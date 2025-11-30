import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class IAuthRepository {
  Future<Either<Failure, User>> login({required String provider, required String token});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}
