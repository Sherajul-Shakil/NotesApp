//This file will hold both todo_item data transfer object
//and note data transfer object

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/src/collection/interop.dart';
import 'package:kt_dart/src/collection/kt_iterable.dart';
import 'package:notes_firebase_ddd/domain/auth/value_objects.dart';
import 'package:notes_firebase_ddd/domain/notes/note.dart';
import 'package:notes_firebase_ddd/domain/notes/todo_item.dart';
import 'package:notes_firebase_ddd/domain/notes/value_objects.dart';
part 'note_dtos.freezed.dart';
part 'note_dtos.g.dart';

@freezed
abstract class NoteDto implements _$NoteDto {
  const factory NoteDto({
    @JsonKey(ignore: true) String? id,
    @required String? body,
    @required int? color,
    @required List<TodoItemDto?>? todos,
    @ServerTimeStampConverter() required FieldValue? serverTimeStamp,
  }) = _NoteDto;

  factory NoteDto.fromDomain(Note note) {
    return NoteDto(
      id: note.id.getOrCrash(),
      body: note.body.getOrCrash(),
      color: note.color.getOrCrash().value,
      todos: note.todos
          .getOrCrash()
          .map(
            (todoItem) => TodoItemDto.fromDomain(todoItem),
          )
          .asList(),
      serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  factory NoteDto.fromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data()! as Map<String, dynamic>);
    return NoteDto.fromJson(data).copyWith(id: doc.id);
  }
  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);

  const NoteDto._();
  Note toDomain() {
    return Note(
      id: UniqueId.fromUniqueString(id!),
      body: NoteBody(body!),
      color: NoteColor(Color(color!)),
      todos: ListThree(todos!.map((dto) => dto!.toDomain()).toImmutableList()),
    );
  }
}

class ServerTimeStampConverter implements JsonConverter<FieldValue?, Object?> {
  const ServerTimeStampConverter();
  @override
  FieldValue? fromJson(Object? json) {
    return FieldValue.serverTimestamp();
  }

  @override
  Object? toJson(FieldValue? fieldValue) => fieldValue;
}

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
