import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l/l.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uneconly/feature/schedule/data/schedule_repository.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

part 'schedule_bloc.freezed.dart';

/* Schedule Events */

@freezed
class ScheduleEvent with _$ScheduleEvent {
  const ScheduleEvent._();

  /// Create
  const factory ScheduleEvent.create({required Schedule itemData}) =
      CreateScheduleEvent;

  /// Fetch
  const factory ScheduleEvent.fetch({int? groupId, int? week}) =
      FetchScheduleEvent;

  /// Update
  const factory ScheduleEvent.update({required Schedule item}) =
      UpdateScheduleEvent;

  /// Delete
  const factory ScheduleEvent.delete({required Schedule item}) =
      DeleteScheduleEvent;
}

/* Schedule States */

@freezed
class ScheduleState with _$ScheduleState {
  const ScheduleState._();

  /// Idling state
  const factory ScheduleState.idle({
    required final Schedule? data,
    @Default('Idle') final String message,
  }) = IdleScheduleState;

  /// Processing
  const factory ScheduleState.processing({
    required final Schedule? data,
    @Default('Processing') final String message,
  }) = ProcessingScheduleState;

  /// Successful
  const factory ScheduleState.successful({
    required final Schedule? data,
    @Default('Successful') final String message,
  }) = SuccessfulScheduleState;

  /// An error has occurred
  const factory ScheduleState.error({
    required final Schedule? data,
    @Default('An error has occurred') final String message,
  }) = ErrorScheduleState;

  /// Has data
  bool get hasData => data != null;

  /// If an error has occurred
  bool get hasError => maybeMap<bool>(orElse: () => false, error: (_) => true);

  /// Is in idle state
  bool get isIdling => !isProcessing;

  /// Is in progress state
  bool get isProcessing =>
      maybeMap<bool>(orElse: () => true, idle: (_) => false);
}

/// Buisiness Logic Component ScheduleBLoC
class ScheduleBLoC extends Bloc<ScheduleEvent, ScheduleState>
    implements EventSink<ScheduleEvent> {
  ScheduleBLoC({
    required final IScheduleRepository repository,
    final ScheduleState? initialState,
  })  : _repository = repository,
        super(
          initialState ??
              const ScheduleState.idle(
                data: Schedule.empty(),
                message: 'Initial idle state',
              ),
        ) {
    on<ScheduleEvent>(
      (event, emit) => event.map<Future<void>>(
        fetch: (event) => _fetch(event, emit),
        create: (value) {
          throw UnimplementedError();
        },
        update: (value) {
          throw UnimplementedError();
        },
        delete: (value) {
          throw UnimplementedError();
        },
      ),
      transformer: bloc_concurrency.sequential(),
    );
  }

  final IScheduleRepository _repository;

  /// Fetch event handler
  Future<void> _fetch(
      FetchScheduleEvent event, Emitter<ScheduleState> emit) async {
    try {
      emit(ScheduleState.processing(data: state.data));
      final newData = await _repository.fetch(
        groupId: event.groupId,
        week: event.week,
      );
      emit(ScheduleState.successful(data: newData));
    } on Object catch (err, stackTrace) {
      l.e('An error occurred in the ScheduleBLoC: $err', stackTrace);
      emit(ScheduleState.error(data: state.data));
      rethrow;
    } finally {
      emit(ScheduleState.idle(data: state.data));
    }
  }
}
