
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_states.freezed.dart';

@freezed
class AuthStates with _$AuthStates {
  const factory AuthStates.initial () = AuthInitial;
  const factory AuthStates.loading () = AuthLoading;
  const factory AuthStates.success () = AuthSuccess;
  const factory AuthStates.error(String error) = AuthError;

}