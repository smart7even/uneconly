import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:l/l.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';
import 'package:uneconly/feature/settings/model/calendar_settings_entity.dart';
import 'package:uneconly/feature/settings/model/settings_entity.dart';

part 'settings_bloc.freezed.dart';

/* Settings Events */

@freezed
class SettingsEvent with _$SettingsEvent {
  const SettingsEvent._();

  @Implements<ISettingsEvent>()
  @With<_ProcessingStateEmitter>()
  @With<_SuccessfulStateEmitter>()
  @With<_ErrorStateEmitter>()
  @With<_IdleStateEmitter>()
  const factory SettingsEvent.create() = CreateSettingsEvent;

  @Implements<ISettingsEvent>()
  @With<_ProcessingStateEmitter>()
  @With<_SuccessfulStateEmitter>()
  @With<_ErrorStateEmitter>()
  @With<_IdleStateEmitter>()
  const factory SettingsEvent.read() = ReadSettingsEvent;

  @Implements<ISettingsEvent>()
  @With<_ProcessingStateEmitter>()
  @With<_SuccessfulStateEmitter>()
  @With<_ErrorStateEmitter>()
  @With<_IdleStateEmitter>()
  const factory SettingsEvent.update({
    required SettingsEntity entity,
  }) = UpdateSettingsEvent;

  @Implements<ISettingsEvent>()
  @With<_ProcessingStateEmitter>()
  @With<_SuccessfulStateEmitter>()
  @With<_ErrorStateEmitter>()
  @With<_IdleStateEmitter>()
  const factory SettingsEvent.delete() = DeleteSettingsEvent;
}

/* Settings States */

@freezed
class SettingsState with _$SettingsState {
  const SettingsState._();

  /// Is in idle state
  bool get idling => !isProcessing;

  /// Is in progress state
  bool get isProcessing => maybeMap<bool>(
        orElse: () => true,
        idle: (_) => false,
      );

  /// If an error has occurred
  bool get hasError => maybeMap<bool>(orElse: () => false, error: (_) => true);

  /// Idling state
  const factory SettingsState.idle({
    required final SettingsEntity? data,
    @Default('Idle') final String message,
  }) = IdleSettingsState;

  /// Processing
  const factory SettingsState.processing({
    required final SettingsEntity? data,
    @Default('Processing') final String message,
  }) = ProcessingSettingsState;

  /// Successful
  const factory SettingsState.successful({
    required final SettingsEntity? data,
    @Default('Successful') final String message,
  }) = SuccessfulSettingsState;

  /// An error has occurred
  const factory SettingsState.error({
    required final SettingsEntity? data,
    @Default('An error has occurred') final String message,
  }) = ErrorSettingsState;
}

/// Buisiness Logic Component SettingsBLoC
class SettingsBLoC extends Bloc<SettingsEvent, SettingsState>
    implements EventSink<SettingsEvent> {
  SettingsBLoC({
    required final ISettingsRepository repository,
    final SettingsState? initialState,
  })  : _repository = repository,
        super(
          initialState ??
              const SettingsState.idle(
                data: null,
                message: 'Initial idle state',
              ),
        ) {
    on<SettingsEvent>(
      (event, emit) => event.map<Future<void>>(
        create: (event) => _create(event, emit),
        read: (event) => _read(event, emit),
        update: (event) => _update(event, emit),
        delete: (event) => _delete(event, emit),
      ),
      transformer: bloc_concurrency.sequential(),
      //transformer: bloc_concurrency.restartable(),
      //transformer: bloc_concurrency.droppable(),
      //transformer: bloc_concurrency.concurrent(),
    );
  }

  final ISettingsRepository _repository;

  /// Create event handler
  Future<void> _create(
    CreateSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    throw UnimplementedError();
    // try {
    //   emit(event.inProgress(state: state));
    //   //final newData = await _repository.();
    //   emit(event.successful(state: state, newData: newData));
    // } on Object catch (err, stackTrace) {
    //   l.e('An error occurred in the SettingsBLoC: $err', stackTrace);
    //   emit(event.error(state: state, message: 'An error occurred'));
    //   rethrow;
    // } finally {
    //   emit(event.idle(state: state));
    // }
  }

  /// Read event handler
  Future<void> _read(
    ReadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(event.inProgress(state: state));
      final themeColor = await _repository.getTheme();
      final calendarSettings = await _repository.getCalendarSettings();

      emit(
        event.successful(
          state: state,
          newData: SettingsEntity(
            themeColor: themeColor ?? '',
            calendarSettings: calendarSettings,
          ),
        ),
      );
    } on Object catch (err, stackTrace) {
      l.e('An error occurred in the SettingsBLoC: $err', stackTrace);
      emit(event.error(state: state, message: 'An error occurred'));
      rethrow;
    } finally {
      emit(event.idle(state: state));
    }
  }

  /// Update event handler
  Future<void> _update(
    UpdateSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(event.inProgress(state: state));
      await _repository.saveTheme(event.entity.themeColor);
      await _repository.saveCalendarSettings(
        event.entity.calendarSettings,
      );
      emit(
        event.successful(
          state: state,
          newData: event.entity,
        ),
      );
    } on Object catch (err, stackTrace) {
      l.e('An error occurred in the SettingsBLoC: $err', stackTrace);
      emit(event.error(state: state, message: 'An error occurred'));
      rethrow;
    } finally {
      emit(event.idle(state: state));
    }
  }

  /// Delete event handler
  Future<void> _delete(
    DeleteSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    throw UnimplementedError();
    // try {
    //   emit(event.inProgress(state: state));
    //   //final newData = await _repository.();
    //   emit(event.successful(state: state, newData: newData));
    // } on Object catch (err, stackTrace) {
    //   l.e('An error occurred in the SettingsBLoC: $err', stackTrace);
    //   emit(event.error(state: state, message: 'An error occurred'));
    //   rethrow;
    // } finally {
    //   emit(event.idle(state: state));
    // }
  }
}

/* Interfaces for events SettingsEvent */

abstract class ISettingsEvent {}

/* Mixins for events SettingsEvent */

mixin _ProcessingStateEmitter on SettingsEvent {
  SettingsState inProgress({
    required final SettingsState state,
    final String? message,
  }) =>
      SettingsState.processing(
        data: state.data,
        message: message ?? 'Processing',
      );
}

mixin _SuccessfulStateEmitter on SettingsEvent {
  SettingsState successful({
    required final SettingsState state,
    final SettingsEntity? newData,
    final String? message,
  }) =>
      SettingsState.successful(
        data: newData ?? state.data,
        message: message ?? 'Successful',
      );
}

mixin _ErrorStateEmitter on SettingsEvent {
  /// An error occurred
  SettingsState error({
    required final SettingsState state,
    final String? message,
  }) =>
      SettingsState.error(
        data: state.data,
        message: message ?? 'An error has occurred',
      );
}

mixin _IdleStateEmitter on SettingsEvent {
  SettingsState idle({
    required final SettingsState state,
    final String? message,
  }) =>
      SettingsState.idle(
        data: state.data,
        message: message ?? 'Idle',
      );
}
