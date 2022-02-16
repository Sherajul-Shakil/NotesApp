import 'package:dartz/dartz.dart';
import 'package:notes_firebase_ddd/domain/auth/value_objects.dart';
import 'package:notes_firebase_ddd/domain/core/core.dart';
import 'package:notes_firebase_ddd/domain/notes/value_objects.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'todo_item.freezed.dart';

@freezed
abstract class TodoItem implements _$TodoItem {
  const factory TodoItem({
    required UniqueId id,
    required TodoName name,
    required bool done,
  }) = _TodoItem;

  const TodoItem._();

  factory TodoItem.empty() => TodoItem(
        id: UniqueId(),
        name: TodoName(''),
        done: false,
      );

//check only name is an error or not
  Option<ValueFailure<dynamic>> get failureOption {
    return name.value.fold(some, (r) => none());
    // (f) => some(f)   shortend to some
  }
}

//return some if any error
//return none if no error