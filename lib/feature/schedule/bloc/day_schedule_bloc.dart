import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uneconly/feature/schedule/data/day_schedule_repository.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/day_schedule_entity.dart';
import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;

part 'day_schedule_bloc.freezed.dart';

/* DaySchedule States */

@freezed
class DayScheduleState with _$DayScheduleState {
  const DayScheduleState._();

  /// Idling state
  const factory DayScheduleState.idle({
    required final DayScheduleEntity? data,
    @Default('Idle') final String message,
  }) = IdleDayScheduleState;

  /// Processing
  const factory DayScheduleState.processing({
    required final DayScheduleEntity? data,
    @Default('Processing') final String message,
  }) = ProcessingDayScheduleState;

  /// Successful
  const factory DayScheduleState.successful({
    required final DayScheduleEntity? data,
    @Default('Successful') final String message,
  }) = SuccessfulDayScheduleState;

  /// An error has occurred
  const factory DayScheduleState.error({
    required final DayScheduleEntity? data,
    @Default('An error has occurred') final String message,
  }) = ErrorDayScheduleState;

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

/* DaySchedule Events */

@freezed
class DayScheduleEvent with _$DayScheduleEvent {
  const DayScheduleEvent._();

  /// Create
  const factory DayScheduleEvent.create({required DaySchedule itemData}) =
      CreateDayScheduleEvent;

  /// Fetch
  const factory DayScheduleEvent.fetch() = FetchDayScheduleEvent;

  // /// Update
  // const factory DayScheduleEvent.update({required Item item}) = UpdateDayScheduleEvent;

  // /// Delete
  // const factory DayScheduleEvent.delete({required Item item}) = DeleteDayScheduleEvent;
}

/// Buisiness Logic Component DayScheduleBLoC
class DayScheduleBLoC extends Bloc<DayScheduleEvent, DayScheduleState>
    implements EventSink<DayScheduleEvent> {
  DayScheduleBLoC({
    required final IDayScheduleRepository repository,
    required final DayScheduleState initialState,
  })  : _repository = repository,
        super(initialState) {
    on<DayScheduleEvent>(
      (event, emit) => event.map<Future<void>>(
        fetch: (event) => _fetch(event, emit),
        create: (event) => throw UnimplementedError(),
      ),
      transformer: bloc_concurrency.sequential(),
      //transformer: bloc_concurrency.restartable(),
      //transformer: bloc_concurrency.droppable(),
      //transformer: bloc_concurrency.concurrent(),
    );
  }

  final IDayScheduleRepository _repository;

  /// Fetch event handler
  Future<void> _fetch(
    FetchDayScheduleEvent event,
    Emitter<DayScheduleState> emit,
  ) async {
    try {
      emit(DayScheduleState.successful(data: state.data));
      final newData = await _repository.fetchContacts();

      emit(
        DayScheduleState.successful(
          data: state.data?.copyWith(
            news: newData,
          ),
        ),
      );
    } on Object catch (err, stackTrace) {
      //l.e('An error occurred in the DayScheduleBLoC: $err', stackTrace);
      emit(DayScheduleState.error(data: state.data));
      rethrow;
    } finally {
      emit(DayScheduleState.idle(data: state.data));
    }
  }
}
