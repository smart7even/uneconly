import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l/l.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/feature/schedule/data/schedule_repository.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/domain/schedule_transformer.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_details.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';

part 'schedule_bloc.freezed.dart';

/* Schedule Events */

@freezed
abstract class ScheduleEvent with _$ScheduleEvent {
  const ScheduleEvent._();

  /// Create
  const factory ScheduleEvent.create({required Schedule itemData}) =
      CreateScheduleEvent;

  /// Fetch
  const factory ScheduleEvent.fetch({
    required int week,
    ScheduleInfo? info,
    int? academicYearStart,
    @Default(false) bool setAsCurrent,
  }) = FetchScheduleEvent;

  const factory ScheduleEvent.changeGroup({
    required int week,
    required ScheduleInfo info,
    int? academicYearStart,
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
abstract class ScheduleState with _$ScheduleState {
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
      maybeMap<bool>(processing: (_) => true, orElse: () => false);

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
    final LessonChoiceRepository? lessonChoiceRepository,
    final ScheduleState? initialState,
  })  : _repository = repository,
        _groupRepository = groupRepository,
        _lessonChoiceRepository = lessonChoiceRepository,
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
      // Loading events intentionally run concurrently. A request that has
      // already reached the repository must be allowed to finish and populate
      // the cache, while [_latestLoadRevision] prevents an obsolete request
      // from publishing UI state after the user selects another week/group.
      transformer: bloc_concurrency.concurrent(),
    );
  }

  final IScheduleRepository _repository;
  final IGroupRepository _groupRepository;
  final LessonChoiceRepository? _lessonChoiceRepository;
  int _latestLoadRevision = 0;

  bool _canPublish(int revision, Emitter<ScheduleState> emit) =>
      revision == _latestLoadRevision && !emit.isDone;

  /// Fetch event handler
  Future<void> _fetch(
    FetchScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final revision = ++_latestLoadRevision;

    try {
      final info = event.info ?? state.scheduleInfo;

      if (info == null) {
        return;
      }

      emit(
        ScheduleState.processing(
          data: state.data,
          currentWeek:
              event.setAsCurrent ? event.week : state.currentWeek ?? event.week,
          selectedWeek: event.week,
          scheduleInfo: info,
        ),
      );

      final localEntry = await _repository.getLocalSchedule(
        info: info,
        week: event.week,
        academicYearStart: event.academicYearStart,
      );

      if (!_canPublish(revision, emit)) {
        return;
      }

      if (localEntry != null) {
        final localSchedule = localEntry.schedule;
        final localData = {
          ...state.data,
        };

        localData[localSchedule.week] = ScheduleDetails(
          schedule: localSchedule,
          isLocal: true,
          updatedAt: localEntry.updatedAt,
        );

        emit(
          ScheduleState.processing(
            data: localData,
            currentWeek: event.setAsCurrent
                ? event.week
                : state.currentWeek ?? localSchedule.week,
            selectedWeek: event.week,
            scheduleInfo: info,
          ),
        );
      }

      if (state.scheduleInfo == null) {
        await info.map(
          group: (group) async {
            final fetchedGroup = await _groupRepository.fetchGroupById(
              group.shortGroupInfo.groupId,
            );

            if (!_canPublish(revision, emit)) {
              return;
            }

            emit(
              ScheduleState.processing(
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

      if (!_canPublish(revision, emit)) {
        return;
      }

      final newData = {
        ...state.data,
      };

      newData[schedule.week] = ScheduleDetails(
        schedule: schedule,
        isLocal: false,
        updatedAt: DateTime.now(),
      );

      emit(ScheduleState.successful(
        data: newData,
        currentWeek: event.setAsCurrent
            ? event.week
            : state.currentWeek ?? schedule.week,
        selectedWeek: event.week,
        scheduleInfo: state.scheduleInfo,
      ));
    } on Object catch (err, stackTrace) {
      l.e('An error occurred in the ScheduleBLoC: $err', stackTrace);
      l.e(stackTrace.toString());
      if (!_canPublish(revision, emit)) {
        return;
      }
      emit(ScheduleState.error(
        data: state.data,
        currentWeek: state.currentWeek,
        selectedWeek: state.selectedWeek,
        scheduleInfo: state.scheduleInfo,
      ));
    }
  }

  Future<void> _changeGroup(
    ChangeGroupScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    if (event.info == state.scheduleInfo) {
      return;
    }

    final revision = ++_latestLoadRevision;
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
        scheduleInfo: info,
      ));

      final localEntry = await _repository.getLocalSchedule(
        info: event.info,
        week: event.week,
        academicYearStart: event.academicYearStart,
      );

      if (!_canPublish(revision, emit)) {
        return;
      }

      if (localEntry != null) {
        final localSchedule = localEntry.schedule;
        final localData = {
          ...state.data,
        };

        localData[localSchedule.week] = ScheduleDetails(
          schedule: localSchedule,
          isLocal: true,
          updatedAt: localEntry.updatedAt,
        );

        emit(ScheduleState.processing(
          data: localData,
          currentWeek: state.currentWeek ?? localSchedule.week,
          selectedWeek: event.week,
          scheduleInfo: info,
        ));
      }

      var resolvedInfo = info;
      await info.map(
        group: (group) async {
          if (group.shortGroupInfo.groupName != null) {
            return;
          }

          final fetchedGroup = await _groupRepository.fetchGroupById(
            group.shortGroupInfo.groupId,
          );

          if (!_canPublish(revision, emit)) {
            return;
          }

          resolvedInfo = ScheduleInfo.group(
            shortGroupInfo: ShortGroupInfo(
              groupId: fetchedGroup.id,
              groupName: fetchedGroup.name,
            ),
          );

          emit(
            ScheduleState.processing(
              data: state.data,
              currentWeek: state.currentWeek ?? event.week,
              selectedWeek: event.week,
              scheduleInfo: resolvedInfo,
            ),
          );
        },
        // Professor route arguments already contain the display name. Unlike
        // groups, there is no separate metadata lookup to perform here.
        professor: (_) async {},
      );

      if (!_canPublish(revision, emit)) {
        return;
      }

      final schedule = await _repository.fetch(
        info: resolvedInfo,
        week: event.week,
      );

      if (!_canPublish(revision, emit)) {
        return;
      }

      final newData = {
        ...state.data,
      };

      newData[schedule.week] = ScheduleDetails(
        schedule: schedule,
        isLocal: false,
        updatedAt: DateTime.now(),
      );

      emit(
        ScheduleState.successful(
          data: newData,
          currentWeek: state.currentWeek ?? schedule.week,
          selectedWeek: event.week,
          scheduleInfo: resolvedInfo,
        ),
      );
    } on Object catch (err, stackTrace) {
      l.e('An error occurred in the ScheduleBLoC: $err', stackTrace);
      if (!_canPublish(revision, emit)) {
        return;
      }
      emit(
        ScheduleState.error(
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

    final title = state.scheduleInfo?.title;

    if (selectedScheduleDetails == null) {
      return;
    }

    final content = ScheduleTransformer().transformScheduleToString(
      selectedScheduleDetails.schedule,
      title,
      choiceRepository: _lessonChoiceRepository,
    );

    event.onShare(content);
  }
}
