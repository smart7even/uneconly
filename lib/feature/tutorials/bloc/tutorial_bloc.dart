import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:l/l.dart';
import 'package:uneconly/feature/tutorials/data/tutorial_repository.dart';
import 'package:uneconly/feature/tutorials/model/tutorial.dart';

part 'tutorial_bloc.freezed.dart';

/* Tutorial Events */

@freezed
class TutorialEvent with _$TutorialEvent {
  const TutorialEvent._();

  @Implements<ITutorialEvent>()
  @With<_ProcessingStateEmitter>()
  @With<_SuccessfulStateEmitter>()
  @With<_ErrorStateEmitter>()
  @With<_IdleStateEmitter>()
  const factory TutorialEvent.create() = CreateTutorialEvent;

  @Implements<ITutorialEvent>()
  @With<_ProcessingStateEmitter>()
  @With<_SuccessfulStateEmitter>()
  @With<_ErrorStateEmitter>()
  @With<_IdleStateEmitter>()
  const factory TutorialEvent.read() = ReadTutorialEvent;

  @Implements<ITutorialEvent>()
  @With<_ProcessingStateEmitter>()
  @With<_SuccessfulStateEmitter>()
  @With<_ErrorStateEmitter>()
  @With<_IdleStateEmitter>()
  const factory TutorialEvent.update() = UpdateTutorialEvent;

  @Implements<ITutorialEvent>()
  @With<_ProcessingStateEmitter>()
  @With<_SuccessfulStateEmitter>()
  @With<_ErrorStateEmitter>()
  @With<_IdleStateEmitter>()
  const factory TutorialEvent.delete() = DeleteTutorialEvent;
}

/* Tutorial States */

@freezed
class TutorialState with _$TutorialState {
  const TutorialState._();

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
  const factory TutorialState.idle({
    required final TutorialEntity data,
    @Default('Idle') final String message,
  }) = IdleTutorialState;

  /// Processing
  const factory TutorialState.processing({
    required final TutorialEntity data,
    @Default('Processing') final String message,
  }) = ProcessingTutorialState;

  /// Successful
  const factory TutorialState.successful({
    required final TutorialEntity data,
    @Default('Successful') final String message,
  }) = SuccessfulTutorialState;

  /// An error has occurred
  const factory TutorialState.error({
    required final TutorialEntity data,
    @Default('An error has occurred') final String message,
  }) = ErrorTutorialState;
}

/// Buisiness Logic Component TutorialBLoC
class TutorialBLoC extends Bloc<TutorialEvent, TutorialState>
    implements EventSink<TutorialEvent> {
  TutorialBLoC({
    required final ITutorialRepository repository,
    final TutorialState? initialState,
  })  : _repository = repository,
        super(
          initialState ??
              TutorialState.idle(
                data: TutorialEntity(
                  news: {},
                ),
                message: 'Initial idle state',
              ),
        ) {
    on<TutorialEvent>(
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

  final ITutorialRepository _repository;

  /// Create event handler
  Future<void> _create(
    CreateTutorialEvent event,
    Emitter<TutorialState> emit,
  ) async {
    return;
    // try {
    //   emit(event.inProgress(state: state));
    //   //final newData = await _repository.();
    //   emit(event.successful(state: state, newData: newData));
    // } on Object catch (err, stackTrace) {
    //   l.e('An error occurred in the TutorialBLoC: $err', stackTrace);
    //   emit(event.error(state: state, message: 'An error occurred'));
    //   rethrow;
    // } finally {
    //   emit(event.idle(state: state));
    // }
  }

  /// Read event handler
  Future<void> _read(
    ReadTutorialEvent event,
    Emitter<TutorialState> emit,
  ) async {
    try {
      emit(event.inProgress(state: state));
      final newData = await _repository.fetchNews().timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Timeout'),
          );
      emit(
        event.successful(
          state: state,
          newData: state.data.copyWith(news: newData),
        ),
      );
    } on Object catch (err, stackTrace) {
      l.e('An error occurred in the TutorialBLoC: $err', stackTrace);
      emit(event.error(state: state, message: 'An error occurred'));
      rethrow;
    } finally {
      emit(event.idle(state: state));
    }
  }

  /// Update event handler
  Future<void> _update(
    UpdateTutorialEvent event,
    Emitter<TutorialState> emit,
  ) async {
    return;
    // try {
    //   emit(event.inProgress(state: state));
    //   final newData = await _repository.();
    //   emit(event.successful(state: state, newData: newData));
    // } on Object catch (err, stackTrace) {
    //   l.e('An error occurred in the TutorialBLoC: $err', stackTrace);
    //   emit(event.error(state: state, message: 'An error occurred'));
    //   rethrow;
    // } finally {
    //   emit(event.idle(state: state));
    // }
  }

  /// Delete event handler
  Future<void> _delete(
    DeleteTutorialEvent event,
    Emitter<TutorialState> emit,
  ) async {
    return;
    // try {
    //   emit(event.inProgress(state: state));
    //   //final newData = await _repository.();
    //   emit(event.successful(state: state, newData: newData));
    // } on Object catch (err, stackTrace) {
    //   l.e('An error occurred in the TutorialBLoC: $err', stackTrace);
    //   emit(event.error(state: state, message: 'An error occurred'));
    //   rethrow;
    // } finally {
    //   emit(event.idle(state: state));
    // }
  }
}

/* Interfaces for events TutorialEvent */

abstract class ITutorialEvent {}

/* Mixins for events TutorialEvent */

/// Creating state "Processing"
mixin _ProcessingStateEmitter on TutorialEvent {
  /// Creating state "Processing"
  TutorialState inProgress({
    required final TutorialState state,
    final String? message,
  }) =>
      TutorialState.processing(
        data: state.data,
        message: message ?? 'Processing',
      );
}

/// Creating state "Successful"
mixin _SuccessfulStateEmitter on TutorialEvent {
  /// Creating state "Successful"
  TutorialState successful({
    required final TutorialState state,
    final TutorialEntity? newData,
    final String? message,
  }) =>
      TutorialState.successful(
        data: newData ?? state.data,
        message: message ?? 'Successful',
      );
}

/// Creating state "Error"
mixin _ErrorStateEmitter on TutorialEvent {
  /// An error occurred
  TutorialState error({
    required final TutorialState state,
    final String? message,
  }) =>
      TutorialState.error(
        data: state.data,
        message: message ?? 'An error has occurred',
      );
}

/// Creating state "Idle"
mixin _IdleStateEmitter on TutorialEvent {
  /// Creating state "Successful"
  /// Idle before getting an event
  TutorialState idle({
    required final TutorialState state,
    final String? message,
  }) =>
      TutorialState.idle(
        data: state.data,
        message: message ?? 'Idle',
      );
}
