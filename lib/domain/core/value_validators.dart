import 'package:dartz/dartz.dart';
import 'package:notes_firebase_ddd/domain/core/failures.dart';
import 'package:kt_dart/kt.dart';

Either<ValueFailure<String>, String> validateEmailAddress({
  required String? email,
}) {
  const emailRegex =
      r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
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

Either<ValueFailure<String>, String> validateMaxStringLength(
  String? input,
  int? maxLength,
) {
  if (input!.length <= maxLength!) {
    return right(input);
  } else {
    return left(
      ValueFailure.exceedingLength(
        failedValue: input,
        max: maxLength,
      ),
    );
  }
}

Either<ValueFailure<String>, String> validateStringNotEmpty(
  String? input,
) {
  if (input!.isNotEmpty) {
    return right(input);
  } else {
    return left(ValueFailure.empty(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validateSingleLine(
  String? input,
) {
  if (!input!.contains('\n')) {
    return right(input);
  } else {
    return left(ValueFailure.empty(failedValue: input));
  }
}

Either<ValueFailure<KtList<T>>, KtList<T>> validateMaxListLength<T>(
  KtList<T>? input,
  int? maxLength,
) {
  if (input!.size <= maxLength!) {
    return right(input);
  } else {
    return left(ValueFailure.listTooLong(
      failedValue: input,
      max: maxLength,
    ));
  }
}
