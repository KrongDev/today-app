import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failures.freezed.dart';

@freezed
class AuthFailure with _$AuthFailure {
  const factory AuthFailure.serverError(String message) = _ServerError;
  const factory AuthFailure.invalidCredentials() = _InvalidCredentials;
  const factory AuthFailure.networkError() = _NetworkError;
  const factory AuthFailure.tokenExpired() = _TokenExpired;
}
