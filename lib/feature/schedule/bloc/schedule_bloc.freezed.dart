// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$ScheduleEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule itemData) create,
    required TResult Function(int id) fetch,
    required TResult Function(Schedule item) update,
    required TResult Function(Schedule item) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule itemData)? create,
    TResult? Function(int id)? fetch,
    TResult? Function(Schedule item)? update,
    TResult? Function(Schedule item)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule itemData)? create,
    TResult Function(int id)? fetch,
    TResult Function(Schedule item)? update,
    TResult Function(Schedule item)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateScheduleEvent value) create,
    required TResult Function(FetchScheduleEvent value) fetch,
    required TResult Function(UpdateScheduleEvent value) update,
    required TResult Function(DeleteScheduleEvent value) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateScheduleEvent value)? create,
    TResult? Function(FetchScheduleEvent value)? fetch,
    TResult? Function(UpdateScheduleEvent value)? update,
    TResult? Function(DeleteScheduleEvent value)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateScheduleEvent value)? create,
    TResult Function(FetchScheduleEvent value)? fetch,
    TResult Function(UpdateScheduleEvent value)? update,
    TResult Function(DeleteScheduleEvent value)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleEventCopyWith<$Res> {
  factory $ScheduleEventCopyWith(
          ScheduleEvent value, $Res Function(ScheduleEvent) then) =
      _$ScheduleEventCopyWithImpl<$Res, ScheduleEvent>;
}

/// @nodoc
class _$ScheduleEventCopyWithImpl<$Res, $Val extends ScheduleEvent>
    implements $ScheduleEventCopyWith<$Res> {
  _$ScheduleEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$CreateScheduleEventCopyWith<$Res> {
  factory _$$CreateScheduleEventCopyWith(_$CreateScheduleEvent value,
          $Res Function(_$CreateScheduleEvent) then) =
      __$$CreateScheduleEventCopyWithImpl<$Res>;
  @useResult
  $Res call({Schedule itemData});
}

/// @nodoc
class __$$CreateScheduleEventCopyWithImpl<$Res>
    extends _$ScheduleEventCopyWithImpl<$Res, _$CreateScheduleEvent>
    implements _$$CreateScheduleEventCopyWith<$Res> {
  __$$CreateScheduleEventCopyWithImpl(
      _$CreateScheduleEvent _value, $Res Function(_$CreateScheduleEvent) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemData = null,
  }) {
    return _then(_$CreateScheduleEvent(
      itemData: null == itemData
          ? _value.itemData
          : itemData // ignore: cast_nullable_to_non_nullable
              as Schedule,
    ));
  }
}

/// @nodoc

class _$CreateScheduleEvent extends CreateScheduleEvent {
  const _$CreateScheduleEvent({required this.itemData}) : super._();

  @override
  final Schedule itemData;

  @override
  String toString() {
    return 'ScheduleEvent.create(itemData: $itemData)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateScheduleEvent &&
            (identical(other.itemData, itemData) ||
                other.itemData == itemData));
  }

  @override
  int get hashCode => Object.hash(runtimeType, itemData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateScheduleEventCopyWith<_$CreateScheduleEvent> get copyWith =>
      __$$CreateScheduleEventCopyWithImpl<_$CreateScheduleEvent>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule itemData) create,
    required TResult Function(int id) fetch,
    required TResult Function(Schedule item) update,
    required TResult Function(Schedule item) delete,
  }) {
    return create(itemData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule itemData)? create,
    TResult? Function(int id)? fetch,
    TResult? Function(Schedule item)? update,
    TResult? Function(Schedule item)? delete,
  }) {
    return create?.call(itemData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule itemData)? create,
    TResult Function(int id)? fetch,
    TResult Function(Schedule item)? update,
    TResult Function(Schedule item)? delete,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(itemData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateScheduleEvent value) create,
    required TResult Function(FetchScheduleEvent value) fetch,
    required TResult Function(UpdateScheduleEvent value) update,
    required TResult Function(DeleteScheduleEvent value) delete,
  }) {
    return create(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateScheduleEvent value)? create,
    TResult? Function(FetchScheduleEvent value)? fetch,
    TResult? Function(UpdateScheduleEvent value)? update,
    TResult? Function(DeleteScheduleEvent value)? delete,
  }) {
    return create?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateScheduleEvent value)? create,
    TResult Function(FetchScheduleEvent value)? fetch,
    TResult Function(UpdateScheduleEvent value)? update,
    TResult Function(DeleteScheduleEvent value)? delete,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(this);
    }
    return orElse();
  }
}

abstract class CreateScheduleEvent extends ScheduleEvent {
  const factory CreateScheduleEvent({required final Schedule itemData}) =
      _$CreateScheduleEvent;
  const CreateScheduleEvent._() : super._();

  Schedule get itemData;
  @JsonKey(ignore: true)
  _$$CreateScheduleEventCopyWith<_$CreateScheduleEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FetchScheduleEventCopyWith<$Res> {
  factory _$$FetchScheduleEventCopyWith(_$FetchScheduleEvent value,
          $Res Function(_$FetchScheduleEvent) then) =
      __$$FetchScheduleEventCopyWithImpl<$Res>;
  @useResult
  $Res call({int id});
}

/// @nodoc
class __$$FetchScheduleEventCopyWithImpl<$Res>
    extends _$ScheduleEventCopyWithImpl<$Res, _$FetchScheduleEvent>
    implements _$$FetchScheduleEventCopyWith<$Res> {
  __$$FetchScheduleEventCopyWithImpl(
      _$FetchScheduleEvent _value, $Res Function(_$FetchScheduleEvent) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$FetchScheduleEvent(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FetchScheduleEvent extends FetchScheduleEvent {
  const _$FetchScheduleEvent({required this.id}) : super._();

  @override
  final int id;

  @override
  String toString() {
    return 'ScheduleEvent.fetch(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchScheduleEvent &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FetchScheduleEventCopyWith<_$FetchScheduleEvent> get copyWith =>
      __$$FetchScheduleEventCopyWithImpl<_$FetchScheduleEvent>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule itemData) create,
    required TResult Function(int id) fetch,
    required TResult Function(Schedule item) update,
    required TResult Function(Schedule item) delete,
  }) {
    return fetch(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule itemData)? create,
    TResult? Function(int id)? fetch,
    TResult? Function(Schedule item)? update,
    TResult? Function(Schedule item)? delete,
  }) {
    return fetch?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule itemData)? create,
    TResult Function(int id)? fetch,
    TResult Function(Schedule item)? update,
    TResult Function(Schedule item)? delete,
    required TResult orElse(),
  }) {
    if (fetch != null) {
      return fetch(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateScheduleEvent value) create,
    required TResult Function(FetchScheduleEvent value) fetch,
    required TResult Function(UpdateScheduleEvent value) update,
    required TResult Function(DeleteScheduleEvent value) delete,
  }) {
    return fetch(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateScheduleEvent value)? create,
    TResult? Function(FetchScheduleEvent value)? fetch,
    TResult? Function(UpdateScheduleEvent value)? update,
    TResult? Function(DeleteScheduleEvent value)? delete,
  }) {
    return fetch?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateScheduleEvent value)? create,
    TResult Function(FetchScheduleEvent value)? fetch,
    TResult Function(UpdateScheduleEvent value)? update,
    TResult Function(DeleteScheduleEvent value)? delete,
    required TResult orElse(),
  }) {
    if (fetch != null) {
      return fetch(this);
    }
    return orElse();
  }
}

abstract class FetchScheduleEvent extends ScheduleEvent {
  const factory FetchScheduleEvent({required final int id}) =
      _$FetchScheduleEvent;
  const FetchScheduleEvent._() : super._();

  int get id;
  @JsonKey(ignore: true)
  _$$FetchScheduleEventCopyWith<_$FetchScheduleEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateScheduleEventCopyWith<$Res> {
  factory _$$UpdateScheduleEventCopyWith(_$UpdateScheduleEvent value,
          $Res Function(_$UpdateScheduleEvent) then) =
      __$$UpdateScheduleEventCopyWithImpl<$Res>;
  @useResult
  $Res call({Schedule item});
}

/// @nodoc
class __$$UpdateScheduleEventCopyWithImpl<$Res>
    extends _$ScheduleEventCopyWithImpl<$Res, _$UpdateScheduleEvent>
    implements _$$UpdateScheduleEventCopyWith<$Res> {
  __$$UpdateScheduleEventCopyWithImpl(
      _$UpdateScheduleEvent _value, $Res Function(_$UpdateScheduleEvent) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
  }) {
    return _then(_$UpdateScheduleEvent(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as Schedule,
    ));
  }
}

/// @nodoc

class _$UpdateScheduleEvent extends UpdateScheduleEvent {
  const _$UpdateScheduleEvent({required this.item}) : super._();

  @override
  final Schedule item;

  @override
  String toString() {
    return 'ScheduleEvent.update(item: $item)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateScheduleEvent &&
            (identical(other.item, item) || other.item == item));
  }

  @override
  int get hashCode => Object.hash(runtimeType, item);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateScheduleEventCopyWith<_$UpdateScheduleEvent> get copyWith =>
      __$$UpdateScheduleEventCopyWithImpl<_$UpdateScheduleEvent>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule itemData) create,
    required TResult Function(int id) fetch,
    required TResult Function(Schedule item) update,
    required TResult Function(Schedule item) delete,
  }) {
    return update(item);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule itemData)? create,
    TResult? Function(int id)? fetch,
    TResult? Function(Schedule item)? update,
    TResult? Function(Schedule item)? delete,
  }) {
    return update?.call(item);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule itemData)? create,
    TResult Function(int id)? fetch,
    TResult Function(Schedule item)? update,
    TResult Function(Schedule item)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(item);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateScheduleEvent value) create,
    required TResult Function(FetchScheduleEvent value) fetch,
    required TResult Function(UpdateScheduleEvent value) update,
    required TResult Function(DeleteScheduleEvent value) delete,
  }) {
    return update(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateScheduleEvent value)? create,
    TResult? Function(FetchScheduleEvent value)? fetch,
    TResult? Function(UpdateScheduleEvent value)? update,
    TResult? Function(DeleteScheduleEvent value)? delete,
  }) {
    return update?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateScheduleEvent value)? create,
    TResult Function(FetchScheduleEvent value)? fetch,
    TResult Function(UpdateScheduleEvent value)? update,
    TResult Function(DeleteScheduleEvent value)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(this);
    }
    return orElse();
  }
}

abstract class UpdateScheduleEvent extends ScheduleEvent {
  const factory UpdateScheduleEvent({required final Schedule item}) =
      _$UpdateScheduleEvent;
  const UpdateScheduleEvent._() : super._();

  Schedule get item;
  @JsonKey(ignore: true)
  _$$UpdateScheduleEventCopyWith<_$UpdateScheduleEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteScheduleEventCopyWith<$Res> {
  factory _$$DeleteScheduleEventCopyWith(_$DeleteScheduleEvent value,
          $Res Function(_$DeleteScheduleEvent) then) =
      __$$DeleteScheduleEventCopyWithImpl<$Res>;
  @useResult
  $Res call({Schedule item});
}

/// @nodoc
class __$$DeleteScheduleEventCopyWithImpl<$Res>
    extends _$ScheduleEventCopyWithImpl<$Res, _$DeleteScheduleEvent>
    implements _$$DeleteScheduleEventCopyWith<$Res> {
  __$$DeleteScheduleEventCopyWithImpl(
      _$DeleteScheduleEvent _value, $Res Function(_$DeleteScheduleEvent) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
  }) {
    return _then(_$DeleteScheduleEvent(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as Schedule,
    ));
  }
}

/// @nodoc

class _$DeleteScheduleEvent extends DeleteScheduleEvent {
  const _$DeleteScheduleEvent({required this.item}) : super._();

  @override
  final Schedule item;

  @override
  String toString() {
    return 'ScheduleEvent.delete(item: $item)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteScheduleEvent &&
            (identical(other.item, item) || other.item == item));
  }

  @override
  int get hashCode => Object.hash(runtimeType, item);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteScheduleEventCopyWith<_$DeleteScheduleEvent> get copyWith =>
      __$$DeleteScheduleEventCopyWithImpl<_$DeleteScheduleEvent>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule itemData) create,
    required TResult Function(int id) fetch,
    required TResult Function(Schedule item) update,
    required TResult Function(Schedule item) delete,
  }) {
    return delete(item);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule itemData)? create,
    TResult? Function(int id)? fetch,
    TResult? Function(Schedule item)? update,
    TResult? Function(Schedule item)? delete,
  }) {
    return delete?.call(item);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule itemData)? create,
    TResult Function(int id)? fetch,
    TResult Function(Schedule item)? update,
    TResult Function(Schedule item)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(item);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateScheduleEvent value) create,
    required TResult Function(FetchScheduleEvent value) fetch,
    required TResult Function(UpdateScheduleEvent value) update,
    required TResult Function(DeleteScheduleEvent value) delete,
  }) {
    return delete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateScheduleEvent value)? create,
    TResult? Function(FetchScheduleEvent value)? fetch,
    TResult? Function(UpdateScheduleEvent value)? update,
    TResult? Function(DeleteScheduleEvent value)? delete,
  }) {
    return delete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateScheduleEvent value)? create,
    TResult Function(FetchScheduleEvent value)? fetch,
    TResult Function(UpdateScheduleEvent value)? update,
    TResult Function(DeleteScheduleEvent value)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(this);
    }
    return orElse();
  }
}

abstract class DeleteScheduleEvent extends ScheduleEvent {
  const factory DeleteScheduleEvent({required final Schedule item}) =
      _$DeleteScheduleEvent;
  const DeleteScheduleEvent._() : super._();

  Schedule get item;
  @JsonKey(ignore: true)
  _$$DeleteScheduleEventCopyWith<_$DeleteScheduleEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ScheduleState {
  Schedule? get data => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule? data, String message) idle,
    required TResult Function(Schedule? data, String message) processing,
    required TResult Function(Schedule? data, String message) successful,
    required TResult Function(Schedule? data, String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule? data, String message)? idle,
    TResult? Function(Schedule? data, String message)? processing,
    TResult? Function(Schedule? data, String message)? successful,
    TResult? Function(Schedule? data, String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule? data, String message)? idle,
    TResult Function(Schedule? data, String message)? processing,
    TResult Function(Schedule? data, String message)? successful,
    TResult Function(Schedule? data, String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleScheduleState value) idle,
    required TResult Function(ProcessingScheduleState value) processing,
    required TResult Function(SuccessfulScheduleState value) successful,
    required TResult Function(ErrorScheduleState value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleScheduleState value)? idle,
    TResult? Function(ProcessingScheduleState value)? processing,
    TResult? Function(SuccessfulScheduleState value)? successful,
    TResult? Function(ErrorScheduleState value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleScheduleState value)? idle,
    TResult Function(ProcessingScheduleState value)? processing,
    TResult Function(SuccessfulScheduleState value)? successful,
    TResult Function(ErrorScheduleState value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScheduleStateCopyWith<ScheduleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleStateCopyWith<$Res> {
  factory $ScheduleStateCopyWith(
          ScheduleState value, $Res Function(ScheduleState) then) =
      _$ScheduleStateCopyWithImpl<$Res, ScheduleState>;
  @useResult
  $Res call({Schedule? data, String message});
}

/// @nodoc
class _$ScheduleStateCopyWithImpl<$Res, $Val extends ScheduleState>
    implements $ScheduleStateCopyWith<$Res> {
  _$ScheduleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Schedule?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdleScheduleStateCopyWith<$Res>
    implements $ScheduleStateCopyWith<$Res> {
  factory _$$IdleScheduleStateCopyWith(
          _$IdleScheduleState value, $Res Function(_$IdleScheduleState) then) =
      __$$IdleScheduleStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Schedule? data, String message});
}

/// @nodoc
class __$$IdleScheduleStateCopyWithImpl<$Res>
    extends _$ScheduleStateCopyWithImpl<$Res, _$IdleScheduleState>
    implements _$$IdleScheduleStateCopyWith<$Res> {
  __$$IdleScheduleStateCopyWithImpl(
      _$IdleScheduleState _value, $Res Function(_$IdleScheduleState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? message = null,
  }) {
    return _then(_$IdleScheduleState(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Schedule?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$IdleScheduleState extends IdleScheduleState {
  const _$IdleScheduleState({required this.data, this.message = 'Idle'})
      : super._();

  @override
  final Schedule? data;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'ScheduleState.idle(data: $data, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdleScheduleState &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdleScheduleStateCopyWith<_$IdleScheduleState> get copyWith =>
      __$$IdleScheduleStateCopyWithImpl<_$IdleScheduleState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule? data, String message) idle,
    required TResult Function(Schedule? data, String message) processing,
    required TResult Function(Schedule? data, String message) successful,
    required TResult Function(Schedule? data, String message) error,
  }) {
    return idle(data, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule? data, String message)? idle,
    TResult? Function(Schedule? data, String message)? processing,
    TResult? Function(Schedule? data, String message)? successful,
    TResult? Function(Schedule? data, String message)? error,
  }) {
    return idle?.call(data, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule? data, String message)? idle,
    TResult Function(Schedule? data, String message)? processing,
    TResult Function(Schedule? data, String message)? successful,
    TResult Function(Schedule? data, String message)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(data, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleScheduleState value) idle,
    required TResult Function(ProcessingScheduleState value) processing,
    required TResult Function(SuccessfulScheduleState value) successful,
    required TResult Function(ErrorScheduleState value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleScheduleState value)? idle,
    TResult? Function(ProcessingScheduleState value)? processing,
    TResult? Function(SuccessfulScheduleState value)? successful,
    TResult? Function(ErrorScheduleState value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleScheduleState value)? idle,
    TResult Function(ProcessingScheduleState value)? processing,
    TResult Function(SuccessfulScheduleState value)? successful,
    TResult Function(ErrorScheduleState value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class IdleScheduleState extends ScheduleState {
  const factory IdleScheduleState(
      {required final Schedule? data,
      final String message}) = _$IdleScheduleState;
  const IdleScheduleState._() : super._();

  @override
  Schedule? get data;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$IdleScheduleStateCopyWith<_$IdleScheduleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProcessingScheduleStateCopyWith<$Res>
    implements $ScheduleStateCopyWith<$Res> {
  factory _$$ProcessingScheduleStateCopyWith(_$ProcessingScheduleState value,
          $Res Function(_$ProcessingScheduleState) then) =
      __$$ProcessingScheduleStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Schedule? data, String message});
}

/// @nodoc
class __$$ProcessingScheduleStateCopyWithImpl<$Res>
    extends _$ScheduleStateCopyWithImpl<$Res, _$ProcessingScheduleState>
    implements _$$ProcessingScheduleStateCopyWith<$Res> {
  __$$ProcessingScheduleStateCopyWithImpl(_$ProcessingScheduleState _value,
      $Res Function(_$ProcessingScheduleState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? message = null,
  }) {
    return _then(_$ProcessingScheduleState(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Schedule?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ProcessingScheduleState extends ProcessingScheduleState {
  const _$ProcessingScheduleState(
      {required this.data, this.message = 'Processing'})
      : super._();

  @override
  final Schedule? data;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'ScheduleState.processing(data: $data, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessingScheduleState &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessingScheduleStateCopyWith<_$ProcessingScheduleState> get copyWith =>
      __$$ProcessingScheduleStateCopyWithImpl<_$ProcessingScheduleState>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule? data, String message) idle,
    required TResult Function(Schedule? data, String message) processing,
    required TResult Function(Schedule? data, String message) successful,
    required TResult Function(Schedule? data, String message) error,
  }) {
    return processing(data, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule? data, String message)? idle,
    TResult? Function(Schedule? data, String message)? processing,
    TResult? Function(Schedule? data, String message)? successful,
    TResult? Function(Schedule? data, String message)? error,
  }) {
    return processing?.call(data, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule? data, String message)? idle,
    TResult Function(Schedule? data, String message)? processing,
    TResult Function(Schedule? data, String message)? successful,
    TResult Function(Schedule? data, String message)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(data, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleScheduleState value) idle,
    required TResult Function(ProcessingScheduleState value) processing,
    required TResult Function(SuccessfulScheduleState value) successful,
    required TResult Function(ErrorScheduleState value) error,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleScheduleState value)? idle,
    TResult? Function(ProcessingScheduleState value)? processing,
    TResult? Function(SuccessfulScheduleState value)? successful,
    TResult? Function(ErrorScheduleState value)? error,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleScheduleState value)? idle,
    TResult Function(ProcessingScheduleState value)? processing,
    TResult Function(SuccessfulScheduleState value)? successful,
    TResult Function(ErrorScheduleState value)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class ProcessingScheduleState extends ScheduleState {
  const factory ProcessingScheduleState(
      {required final Schedule? data,
      final String message}) = _$ProcessingScheduleState;
  const ProcessingScheduleState._() : super._();

  @override
  Schedule? get data;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$ProcessingScheduleStateCopyWith<_$ProcessingScheduleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SuccessfulScheduleStateCopyWith<$Res>
    implements $ScheduleStateCopyWith<$Res> {
  factory _$$SuccessfulScheduleStateCopyWith(_$SuccessfulScheduleState value,
          $Res Function(_$SuccessfulScheduleState) then) =
      __$$SuccessfulScheduleStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Schedule? data, String message});
}

/// @nodoc
class __$$SuccessfulScheduleStateCopyWithImpl<$Res>
    extends _$ScheduleStateCopyWithImpl<$Res, _$SuccessfulScheduleState>
    implements _$$SuccessfulScheduleStateCopyWith<$Res> {
  __$$SuccessfulScheduleStateCopyWithImpl(_$SuccessfulScheduleState _value,
      $Res Function(_$SuccessfulScheduleState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? message = null,
  }) {
    return _then(_$SuccessfulScheduleState(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Schedule?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SuccessfulScheduleState extends SuccessfulScheduleState {
  const _$SuccessfulScheduleState(
      {required this.data, this.message = 'Successful'})
      : super._();

  @override
  final Schedule? data;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'ScheduleState.successful(data: $data, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessfulScheduleState &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessfulScheduleStateCopyWith<_$SuccessfulScheduleState> get copyWith =>
      __$$SuccessfulScheduleStateCopyWithImpl<_$SuccessfulScheduleState>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule? data, String message) idle,
    required TResult Function(Schedule? data, String message) processing,
    required TResult Function(Schedule? data, String message) successful,
    required TResult Function(Schedule? data, String message) error,
  }) {
    return successful(data, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule? data, String message)? idle,
    TResult? Function(Schedule? data, String message)? processing,
    TResult? Function(Schedule? data, String message)? successful,
    TResult? Function(Schedule? data, String message)? error,
  }) {
    return successful?.call(data, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule? data, String message)? idle,
    TResult Function(Schedule? data, String message)? processing,
    TResult Function(Schedule? data, String message)? successful,
    TResult Function(Schedule? data, String message)? error,
    required TResult orElse(),
  }) {
    if (successful != null) {
      return successful(data, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleScheduleState value) idle,
    required TResult Function(ProcessingScheduleState value) processing,
    required TResult Function(SuccessfulScheduleState value) successful,
    required TResult Function(ErrorScheduleState value) error,
  }) {
    return successful(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleScheduleState value)? idle,
    TResult? Function(ProcessingScheduleState value)? processing,
    TResult? Function(SuccessfulScheduleState value)? successful,
    TResult? Function(ErrorScheduleState value)? error,
  }) {
    return successful?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleScheduleState value)? idle,
    TResult Function(ProcessingScheduleState value)? processing,
    TResult Function(SuccessfulScheduleState value)? successful,
    TResult Function(ErrorScheduleState value)? error,
    required TResult orElse(),
  }) {
    if (successful != null) {
      return successful(this);
    }
    return orElse();
  }
}

abstract class SuccessfulScheduleState extends ScheduleState {
  const factory SuccessfulScheduleState(
      {required final Schedule? data,
      final String message}) = _$SuccessfulScheduleState;
  const SuccessfulScheduleState._() : super._();

  @override
  Schedule? get data;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$SuccessfulScheduleStateCopyWith<_$SuccessfulScheduleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorScheduleStateCopyWith<$Res>
    implements $ScheduleStateCopyWith<$Res> {
  factory _$$ErrorScheduleStateCopyWith(_$ErrorScheduleState value,
          $Res Function(_$ErrorScheduleState) then) =
      __$$ErrorScheduleStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Schedule? data, String message});
}

/// @nodoc
class __$$ErrorScheduleStateCopyWithImpl<$Res>
    extends _$ScheduleStateCopyWithImpl<$Res, _$ErrorScheduleState>
    implements _$$ErrorScheduleStateCopyWith<$Res> {
  __$$ErrorScheduleStateCopyWithImpl(
      _$ErrorScheduleState _value, $Res Function(_$ErrorScheduleState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? message = null,
  }) {
    return _then(_$ErrorScheduleState(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Schedule?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorScheduleState extends ErrorScheduleState {
  const _$ErrorScheduleState(
      {required this.data, this.message = 'An error has occurred'})
      : super._();

  @override
  final Schedule? data;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'ScheduleState.error(data: $data, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorScheduleState &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorScheduleStateCopyWith<_$ErrorScheduleState> get copyWith =>
      __$$ErrorScheduleStateCopyWithImpl<_$ErrorScheduleState>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Schedule? data, String message) idle,
    required TResult Function(Schedule? data, String message) processing,
    required TResult Function(Schedule? data, String message) successful,
    required TResult Function(Schedule? data, String message) error,
  }) {
    return error(data, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Schedule? data, String message)? idle,
    TResult? Function(Schedule? data, String message)? processing,
    TResult? Function(Schedule? data, String message)? successful,
    TResult? Function(Schedule? data, String message)? error,
  }) {
    return error?.call(data, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Schedule? data, String message)? idle,
    TResult Function(Schedule? data, String message)? processing,
    TResult Function(Schedule? data, String message)? successful,
    TResult Function(Schedule? data, String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(data, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleScheduleState value) idle,
    required TResult Function(ProcessingScheduleState value) processing,
    required TResult Function(SuccessfulScheduleState value) successful,
    required TResult Function(ErrorScheduleState value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleScheduleState value)? idle,
    TResult? Function(ProcessingScheduleState value)? processing,
    TResult? Function(SuccessfulScheduleState value)? successful,
    TResult? Function(ErrorScheduleState value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleScheduleState value)? idle,
    TResult Function(ProcessingScheduleState value)? processing,
    TResult Function(SuccessfulScheduleState value)? successful,
    TResult Function(ErrorScheduleState value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ErrorScheduleState extends ScheduleState {
  const factory ErrorScheduleState(
      {required final Schedule? data,
      final String message}) = _$ErrorScheduleState;
  const ErrorScheduleState._() : super._();

  @override
  Schedule? get data;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$ErrorScheduleStateCopyWith<_$ErrorScheduleState> get copyWith =>
      throw _privateConstructorUsedError;
}
