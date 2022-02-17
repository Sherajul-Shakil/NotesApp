//This file will hold both todo_item data transfer object
//and note data transfer object

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:notes_firebase_ddd/domain/auth/value_objects.dart';
import 'package:notes_firebase_ddd/domain/notes/todo_item.dart';
import 'package:notes_firebase_ddd/domain/notes/value_objects.dart';
part 'note_dtos.freezed.dart';
part 'note_dtos.g.dart';

@freezed
abstract class TodoItemDto implements _$TodoItemDto {
  const factory TodoItemDto({
    required String? id,
    required String? name,
    required bool? done,
  }) = _TodoItemDto;

  factory TodoItemDto.fromJson(Map<String, dynamic> json) =>
      _$TodoItemDtoFromJson(json);

  factory TodoItemDto.fromDomain(TodoItem todoItem) {
    return TodoItemDto(
        id: todoItem.id.getOrCrash(),
        name: todoItem.name.getOrCrash(),
        done: todoItem.done);
  }

  const TodoItemDto._();
  TodoItem toDomain() {
    return TodoItem(
      id: UniqueId.fromUniqueString(id!),
      name: TodoName(name!),
      done: done!,
    );
  }
}
