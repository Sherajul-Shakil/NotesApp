import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_failure.freezed.dart';

@freezed
abstract class AuthFailure with _$AuthFailure {
  const factory AuthFailure.cancelledByUser() = CancelledByUser;
  const factory AuthFailure.serverError() = ServerError;
  const factory AuthFailure.emailAlreadyUsed() = EmailAlreadyUsed;
  const factory AuthFailure.invalidEmailandPasswordCombination() =
      InvalidEmailandPasswordCombination;
}

// abstract class AuthFailure with _$AuthFailure {
//   const factory AuthFailure.cancelledByUser() = CancelledByUser;
//   // Serves as a "catch all" failure if we don't know what exactly went wrong
//   const factory AuthFailure.serverError() = ServerError;
//   const factory AuthFailure.emailAlreadyInUse() = EmailAlreadyInUse;
//   const factory AuthFailure.invalidEmailAndPasswordCombination() =
//       InvalidEmailAndPasswordCombination;
// }