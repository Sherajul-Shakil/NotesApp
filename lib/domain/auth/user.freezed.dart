// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$AsUserTearOff {
  const _$AsUserTearOff();

  _AsUser call({required UniqueId id}) {
    return _AsUser(
      id: id,
    );
  }
}

/// @nodoc
const $AsUser = _$AsUserTearOff();

/// @nodoc
mixin _$AsUser {
  UniqueId get id => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AsUserCopyWith<AsUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AsUserCopyWith<$Res> {
  factory $AsUserCopyWith(AsUser value, $Res Function(AsUser) then) =
      _$AsUserCopyWithImpl<$Res>;
  $Res call({UniqueId id});
}

/// @nodoc
class _$AsUserCopyWithImpl<$Res> implements $AsUserCopyWith<$Res> {
  _$AsUserCopyWithImpl(this._value, this._then);

  final AsUser _value;
  // ignore: unused_field
  final $Res Function(AsUser) _then;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UniqueId,
    ));
  }
}

/// @nodoc
abstract class _$AsUserCopyWith<$Res> implements $AsUserCopyWith<$Res> {
  factory _$AsUserCopyWith(_AsUser value, $Res Function(_AsUser) then) =
      __$AsUserCopyWithImpl<$Res>;
  @override
  $Res call({UniqueId id});
}

/// @nodoc
class __$AsUserCopyWithImpl<$Res> extends _$AsUserCopyWithImpl<$Res>
    implements _$AsUserCopyWith<$Res> {
  __$AsUserCopyWithImpl(_AsUser _value, $Res Function(_AsUser) _then)
      : super(_value, (v) => _then(v as _AsUser));

  @override
  _AsUser get _value => super._value as _AsUser;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(_AsUser(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UniqueId,
    ));
  }
}

/// @nodoc

class _$_AsUser implements _AsUser {
  const _$_AsUser({required this.id});

  @override
  final UniqueId id;

  @override
  String toString() {
    return 'AsUser(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AsUser &&
            const DeepCollectionEquality().equals(other.id, id));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
  _$AsUserCopyWith<_AsUser> get copyWith =>
      __$AsUserCopyWithImpl<_AsUser>(this, _$identity);
}

abstract class _AsUser implements AsUser {
  const factory _AsUser({required UniqueId id}) = _$_AsUser;

  @override
  UniqueId get id;
  @override
  @JsonKey(ignore: true)
  _$AsUserCopyWith<_AsUser> get copyWith => throw _privateConstructorUsedError;
}
