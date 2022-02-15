import 'package:dartz/dartz.dart';
import 'package:notes_firebase_ddd/domain/core/failures.dart';

Either<ValueFailure<String>, String> validateEmailAddress({
  required String? email,
}) {
  const emailRegex = r'''^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$''';
  if (RegExp(emailRegex).hasMatch(email!)) {
    return right(email);
  } else {
    return left(ValueFailure.invalidEmail(failedValue: email));
  }
}

Either<ValueFailure<String>, String> validatePassword({
  required String? password,
}) {
  if (password!.length >= 6) {
    return right(password);
  } else {
    return left(ValueFailure.shortPassword(failedValue: password));
  }
}
// Either<ValueFailure<String>, String> validateEmailAddress(String input) {
//   const emailRegex =
//       r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
//   if (RegExp(emailRegex).hasMatch(input)) {
//     return Right(input);
//   } else {
//     return left(ValueFailure.invalidEmail(failedValue: input));
//   }
// }

// Either<ValueFailure<String>, String> validatePassword(String input) {
//   if (input.length >= 6) {
//     return right(input);
//   } else {
//     return left(ValueFailure.shortPassword(failedValue: input));
//   }
// }
