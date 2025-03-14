import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l/l.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/feature/schedule/data/schedule_repository.dart';
import 'package:uneconly/feature/schedule/domain/schedule_transformer.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_details.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';

part 'schedule_bloc.freezed.dart';

/* Schedule Events */

@freezed
class ScheduleEvent with _$ScheduleEvent {
  const ScheduleEvent._();

  /// Create
  const factory ScheduleEvent.create({required Schedule itemData}) =
      CreateScheduleEvent;

  /// Fetch
  const factory ScheduleEvent.fetch({
    required int week,
    ScheduleInfo? info,
  }) = FetchScheduleEvent;

  const factory ScheduleEvent.changeGroup({
    required int week,
    required ScheduleInfo info,
  }) = ChangeGroupScheduleEvent;

  /// Update
  const factory ScheduleEvent.update({required Schedule item}) =
      UpdateScheduleEvent;

  /// Delete
  const factory ScheduleEvent.delete({required Schedule item}) =
      DeleteScheduleEvent;

  /// Share
  const factory ScheduleEvent.share(ValueChanged<String> onShare) =
      ShareScheduleEvent;
}

/* Schedule States */

@freezed
class ScheduleState with _$ScheduleState {
  const ScheduleState._();

  /// Idling state
  const factory ScheduleState.idle({
    required final int? currentWeek,
    required final Map<int, ScheduleDetails> data,
    required final ScheduleInfo? scheduleInfo,
    final int? selectedWeek,
    @Default('Idle') final String message,
  }) = IdleScheduleState;

  /// Processing
  const factory ScheduleState.processing({
    required final int? currentWeek,
    required final Map<int, ScheduleDetails> data,
    required final ScheduleInfo? scheduleInfo,
    final int? selectedWeek,
    @Default('Processing') final String message,
  }) = ProcessingScheduleState;

  /// Successful
  const factory ScheduleState.successful({
    required final int? currentWeek,
    required final Map<int, ScheduleDetails> data,
    required final ScheduleInfo? scheduleInfo,
    final int? selectedWeek,
    @Default('Successful') final String message,
  }) = SuccessfulScheduleState;

  /// An error has occurred
  const factory ScheduleState.error({
    required final int? currentWeek,
    required final Map<int, ScheduleDetails> data,
    required final ScheduleInfo? scheduleInfo,
    final int? selectedWeek,
    @Default('An error has occurred') final String message,
  }) = ErrorScheduleState;

  /// Has data
  bool get hasData => data.isNotEmpty;

  /// If an error has occurred
  bool get hasError => maybeMap<bool>(orElse: () => false, error: (_) => true);

  /// Is in idle state
  bool get isIdling => !isProcessing;

  /// Is in progress state
  bool get isProcessing =>
      maybeMap<bool>(orElse: () => true, idle: (_) => false);

  ScheduleDetails? getSelectedScheduleDetails() {
    if (selectedWeek == null) {
      return null;
    }

    return data[selectedWeek];
  }

  ScheduleDetails? getCurrentScheduleDetails() {
    if (currentWeek == null) {
      return null;
    }

    return data[currentWeek];
  }
}

/// Buisiness Logic Component ScheduleBLoC
class ScheduleBLoC extends Bloc<ScheduleEvent, ScheduleState>
    implements EventSink<ScheduleEvent> {
  ScheduleBLoC({
    required final IScheduleRepository repository,
    required final IGroupRepository groupRepository,
    final ScheduleState? initialState,
  })  : _repository = repository,
        _groupRepository = groupRepository,
        super(
          initialState ??
              const ScheduleState.idle(
                selectedWeek: null,
                currentWeek: null,
                data: {},
                scheduleInfo: null,
                message: 'Initial idle state',
              ),
        ) {
    on<ScheduleEvent>(
      (event, emit) => event.map<Future<void>>(
        fetch: (event) => _fetch(event, emit),
        create: (event) {
          throw UnimplementedError();
        },
        update: (event) {
          throw UnimplementedError();
        },
        delete: (event) {
          throw UnimplementedError();
        },
        changeGroup: (event) => _changeGroup(event, emit),
        share: (event) => _share(event, emit),
      ),
      transformer: bloc_concurrency.sequential(),
    );
  }

  final IScheduleRepository _repository;
  final IGroupRepository _groupRepository;

  /// Fetch event handler
  Future<void> _fetch(
    FetchScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      final info = event.info ?? state.scheduleInfo;

      if (info == null) {
        return;
      }

      emit(
        ScheduleState.processing(
          data: state.data,
          currentWeek: state.currentWeek ?? event.week,
          selectedWeek: event.week,
          scheduleInfo: info,
        ),
      );

      final localSchedule = await _repository.getLocalSchedule(
        info: info,
        week: event.week,
      );

      if (localSchedule != null) {
        final localData = {
          ...state.data,
        };

        localData[localSchedule.week] = ScheduleDetails(
          schedule: localSchedule,
          isLocal: true,
        );

        emit(
          ScheduleState.successful(
            data: localData,
            currentWeek: state.currentWeek ?? localSchedule.week,
            selectedWeek: event.week,
            scheduleInfo: state.scheduleInfo,
          ),
        );
      }

      if (state.scheduleInfo == null) {
        await info.map(
          group: (group) async {
            final fetchedGroup = await _groupRepository.fetchGroupById(
              group.shortGroupInfo.groupId,
            );

            emit(
              ScheduleState.successful(
                data: state.data,
                currentWeek: state.currentWeek ?? event.week,
                selectedWeek: event.week,
                scheduleInfo: ScheduleInfo.group(
                  shortGroupInfo: ShortGroupInfo(
                    groupId: fetchedGroup.id,
                    groupName: fetchedGroup.name,
                  ),
                ),
              ),
            );
          },
          professor: (professor) {},
        );
      }

      final schedule = await _repository.fetch(
        info: info,
        week: event.week,
      );

      final newData = {
        ...state.data,
      };

      newData[schedule.week] = ScheduleDetails(
        schedule: schedule,
        isLocal: false,
      );

      emit(ScheduleState.successful(
        data: newData,
        currentWeek: state.currentWeek ?? schedule.week,
        selectedWeek: event.week,
        scheduleInfo: state.scheduleInfo,
      ));
    } on Object catch (err, stackTrace) {
      l.e('An error occurred in the ScheduleBLoC: $err', stackTrace);
      emit(ScheduleState.error(
        data: state.data,
        currentWeek: state.currentWeek,
        selectedWeek: state.selectedWeek,
        scheduleInfo: state.scheduleInfo,
      ));
      rethrow;
    } finally {
      emit(
        ScheduleState.idle(
          data: state.data,
          currentWeek: state.currentWeek,
          selectedWeek: state.selectedWeek,
          scheduleInfo: state.scheduleInfo,
        ),
      );
    }
  }

  Future<void> _changeGroup(
    ChangeGroupScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    if (event.info == state.scheduleInfo) {
      return;
    }

    final info = event.info;

    emit(
      state.copyWith(
        data: {},
      ),
    );

    try {
      emit(ScheduleState.processing(
        data: state.data,
        currentWeek: state.currentWeek ?? event.week,
        selectedWeek: event.week,
        scheduleInfo: state.scheduleInfo,
      ));

      final localSchedule = await _repository.getLocalSchedule(
        info: event.info,
        week: event.week,
      );

      if (localSchedule != null) {
        final localData = {
          ...state.data,
        };

        localData[localSchedule.week] = ScheduleDetails(
          schedule: localSchedule,
          isLocal: true,
        );

        emit(ScheduleState.successful(
          data: localData,
          currentWeek: state.currentWeek ?? localSchedule.week,
          selectedWeek: event.week,
          scheduleInfo: state.scheduleInfo,
        ));
      }

      await info.map(
        group: (group) async {
          ScheduleInfo info = group;

          if (group.shortGroupInfo.groupName == null) {
            final fetchedGroup = await _groupRepository.fetchGroupById(
              group.shortGroupInfo.groupId,
            );

            final newInfo = ScheduleInfo.group(
              shortGroupInfo: ShortGroupInfo(
                groupId: fetchedGroup.id,
                groupName: fetchedGroup.name,
              ),
            );

            info = newInfo;

            emit(
              ScheduleState.successful(
                data: state.data,
                currentWeek: state.currentWeek ?? event.week,
                selectedWeek: event.week,
                scheduleInfo: newInfo,
              ),
            );
          }

          final schedule = await _repository.fetch(
            info: info,
            week: event.week,
          );

          final newData = {
            ...state.data,
          };

          newData[schedule.week] = ScheduleDetails(
            schedule: schedule,
            isLocal: false,
          );

          emit(
            ScheduleState.successful(
              data: newData,
              currentWeek: state.currentWeek ?? schedule.week,
              selectedWeek: event.week,
              scheduleInfo: info,
            ),
          );
        },
        professor: (professor) {},
      );
    } on Object catch (err, stackTrace) {
      l.e('An error occurred in the ScheduleBLoC: $err', stackTrace);
      emit(
        ScheduleState.error(
          data: state.data,
          currentWeek: state.currentWeek,
          selectedWeek: state.selectedWeek,
          scheduleInfo: state.scheduleInfo,
        ),
      );
      rethrow;
    } finally {
      emit(
        ScheduleState.idle(
          data: state.data,
          currentWeek: state.currentWeek,
          selectedWeek: state.selectedWeek,
          scheduleInfo: state.scheduleInfo,
        ),
      );
    }
  }

  Future<void> _share(
    ShareScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final selectedScheduleDetails = state.getSelectedScheduleDetails();

    await state.scheduleInfo?.map(
      group: (group) async {
        final groupInfo = group.shortGroupInfo;

        if (selectedScheduleDetails == null) {
          return;
        }

        final content = ScheduleTransformer().transformScheduleToString(
          selectedScheduleDetails.schedule,
          groupInfo,
        );

        event.onShare(content);
      },
      professor: (professor) {},
    );
  }
}
