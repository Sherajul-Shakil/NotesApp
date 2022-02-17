// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'note_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TodoItemDto _$TodoItemDtoFromJson(Map<String, dynamic> json) {
  return _TodoItemDto.fromJson(json);
}

/// @nodoc
class _$TodoItemDtoTearOff {
  const _$TodoItemDtoTearOff();

  _TodoItemDto call(
      {required String? id, required String? name, required bool? done}) {
    return _TodoItemDto(
      id: id,
      name: name,
      done: done,
    );
  }

  TodoItemDto fromJson(Map<String, Object?> json) {
    return TodoItemDto.fromJson(json);
  }
}

/// @nodoc
const $TodoItemDto = _$TodoItemDtoTearOff();

/// @nodoc
mixin _$TodoItemDto {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  bool? get done => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TodoItemDtoCopyWith<TodoItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoItemDtoCopyWith<$Res> {
  factory $TodoItemDtoCopyWith(
          TodoItemDto value, $Res Function(TodoItemDto) then) =
      _$TodoItemDtoCopyWithImpl<$Res>;
  $Res call({String? id, String? name, bool? done});
}

/// @nodoc
class _$TodoItemDtoCopyWithImpl<$Res> implements $TodoItemDtoCopyWith<$Res> {
  _$TodoItemDtoCopyWithImpl(this._value, this._then);

  final TodoItemDto _value;
  // ignore: unused_field
  final $Res Function(TodoItemDto) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? done = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      done: done == freezed
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
abstract class _$TodoItemDtoCopyWith<$Res>
    implements $TodoItemDtoCopyWith<$Res> {
  factory _$TodoItemDtoCopyWith(
          _TodoItemDto value, $Res Function(_TodoItemDto) then) =
      __$TodoItemDtoCopyWithImpl<$Res>;
  @override
  $Res call({String? id, String? name, bool? done});
}

/// @nodoc
class __$TodoItemDtoCopyWithImpl<$Res> extends _$TodoItemDtoCopyWithImpl<$Res>
    implements _$TodoItemDtoCopyWith<$Res> {
  __$TodoItemDtoCopyWithImpl(
      _TodoItemDto _value, $Res Function(_TodoItemDto) _then)
      : super(_value, (v) => _then(v as _TodoItemDto));

  @override
  _TodoItemDto get _value => super._value as _TodoItemDto;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? done = freezed,
  }) {
    return _then(_TodoItemDto(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      done: done == freezed
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TodoItemDto extends _TodoItemDto {
  const _$_TodoItemDto(
      {required this.id, required this.name, required this.done})
      : super._();

  factory _$_TodoItemDto.fromJson(Map<String, dynamic> json) =>
      _$$_TodoItemDtoFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  final bool? done;

  @override
  String toString() {
    return 'TodoItemDto(id: $id, name: $name, done: $done)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TodoItemDto &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.done, done));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(done));

  @JsonKey(ignore: true)
  @override
  _$TodoItemDtoCopyWith<_TodoItemDto> get copyWith =>
      __$TodoItemDtoCopyWithImpl<_TodoItemDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TodoItemDtoToJson(this);
  }
}

abstract class _TodoItemDto extends TodoItemDto {
  const factory _TodoItemDto(
      {required String? id,
      required String? name,
      required bool? done}) = _$_TodoItemDto;
  const _TodoItemDto._() : super._();

  factory _TodoItemDto.fromJson(Map<String, dynamic> json) =
      _$_TodoItemDto.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  bool? get done;
  @override
  @JsonKey(ignore: true)
  _$TodoItemDtoCopyWith<_TodoItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}
