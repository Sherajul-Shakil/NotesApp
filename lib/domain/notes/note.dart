import 'package:dartz/dartz.dart';
import 'package:notes_firebase_ddd/domain/auth/value_objects.dart';
import 'package:notes_firebase_ddd/domain/core/core.dart';
import 'package:notes_firebase_ddd/domain/notes/todo_item.dart';
import 'package:notes_firebase_ddd/domain/notes/value_objects.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';

part 'note.freezed.dart';

@freezed
abstract class Note implements _$Note {
  const factory Note({
    required UniqueId id,
    required NoteBody body,
    required NoteColor color,
    required ListThree<TodoItem> todos,
  }) = _Note;
  const Note._();

  factory Note.empty() => Note(
        id: UniqueId(),
        body: NoteBody(''),
        color: NoteColor(NoteColor.predefinedColors[0]),
        todos: ListThree(emptyList()),
      );

  Option<ValueFailure<dynamic>> get failureOption {
    return body.failureOrUnit //take all kinds off failure and return one type
        .andThen<Unit>(todos.failureOrUnit)
        .andThen<Unit>(
          todos
              .getOrCrash()
              .map((todoItem) => todoItem.failureOption)
              .filter((o) => o.isSome())
              .getOrElse(0, (_) => none())
              //checking atleast 1 element. if not then none if yes then it's valid
              .fold(() => right(unit), (l) => left(l as ValueFailure<String>)),
        )
        .map((r) => null)
        .fold((f) => some(f as ValueFailure<String>), (r) => none());
  }
}
