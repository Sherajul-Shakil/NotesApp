import 'dart:ui';
import 'package:dartz/dartz.dart';
import 'package:notes_firebase_ddd/domain/core/core.dart';
import 'package:notes_firebase_ddd/domain/core/value_transformers.dart';
import 'package:kt_dart/kt.dart';

class NoteBody extends ValueObject<String> {
  factory NoteBody(String input) {
    return NoteBody._(
      validateMaxStringLength(
        input,
        maxLength,
      ).flatMap(validateStringNotEmpty),
      //check 1st condition and then second condition.
      //if first condition is false then skip second condition
      //kind of middlewares in express.js
    );
  }
  const NoteBody._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
  static const maxLength = 1000;
}

class TodoName extends ValueObject<String> {
  factory TodoName(String input) {
    return TodoName._(
      validateMaxStringLength(input, maxLength)
          .flatMap(validateStringNotEmpty)
          .flatMap(validateSingleLine),
      //(a) => pFunc(func(a));
      // instead we can write
      //  pFunc(func)
    );
  }
  const TodoName._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
  static const maxLength = 30;
}

class NoteColor extends ValueObject<Color> {
  factory NoteColor(Color input) {
    return NoteColor._(right(makeColorOpaque(input)));
  }
  const NoteColor._(this.value);

  @override
  final Either<ValueFailure<Color>, Color> value;
  static const List<Color> predefinedColors = [
    Color(0xfffafafa), // canvas
    Color(0xfffa8072), // salmon
    Color(0xfffedc56), // mustard
    Color(0xffd0f0c0), // tea
    Color(0xfffca3b7), // flamingo
    Color(0xff997950), // tortilla
    Color(0xfffffdd0), // cream
  ];
}

class ListThree<T> extends ValueObject<KtList<T>> {
  factory ListThree(KtList<T> input) {
    return ListThree._(
      validateMaxListLength(input, maxLength),
    );
  }
  const ListThree._(this.value);

  @override
  final Either<ValueFailure<KtList<T>>, KtList<T>> value;
  static const maxLength = 3;
  int get length => value.getOrElse(emptyList).size;
  bool get isFull => length == maxLength;
}
