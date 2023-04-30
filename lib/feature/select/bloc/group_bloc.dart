import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';
import 'package:uneconly/feature/select/model/group.dart';

part 'group_bloc.freezed.dart';
part 'group_bloc.g.dart';

/// GroupEvent data class
@freezed
class GroupEvent with _$GroupEvent {
  const factory GroupEvent.intiial() = _InitialGroupEvent;

  const GroupEvent._();

  /// Generate GroupEvent class from Map<String, Object?>
  factory GroupEvent.fromJson(Map<String, Object?> json) =>
      _$GroupEventFromJson(json);
}

/// GroupState data class
/// GroupState is a union class
/// It can be in one of the following states:
/// - IdleGroupState
/// - ProcessingGroupState
/// - SuccessfulGroupState
/// - ErrorGroupState

@freezed
class GroupState with _$GroupState {
  const GroupState._();

  /// Idle state
  const factory GroupState.idle({
    @Default('Idle') final String message,
    required final List<Group> groups,
  }) = IdleGroupState;

  /// Processing state
  const factory GroupState.processing({
    @Default('Processing') final String message,
    required final List<Group> groups,
  }) = ProcessingGroupState;

  /// Successful state
  const factory GroupState.successful({
    @Default('Successful') final String message,
    required final List<Group> groups,
  }) = SuccessfulGroupState;

  /// Error state
  const factory GroupState.error({
    @Default('Error') final String message,
    required final List<Group> groups,
  }) = ErrorGroupState;
}

/// GroupBloc class
/// GroupBloc is a state management class
/// It can be in one of the following states:
/// - IdleGroupState
/// - ProcessingGroupState
/// - SuccessfulGroupState
/// - ErrorGroupState

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final IGroupRepository _groupRepository;

  GroupBloc({required IGroupRepository groupRepository})
      : _groupRepository = groupRepository,
        super(
          const GroupState.idle(groups: []),
        ) {
    on<GroupEvent>(
      (event, emit) async {
        await event.map(
          intiial: (e) async {
            await _mapInitialToState(e, emit);
          },
        );
      },
    );
  }

  Future<void> _mapInitialToState(
    _InitialGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupState.processing(
      groups: state.groups,
    ));
    try {
      final groups = await _groupRepository.fetchAll();
      emit(GroupState.successful(
        groups: groups,
      ));
    } catch (e) {
      emit(GroupState.error(groups: state.groups));
    } finally {
      emit(GroupState.idle(groups: state.groups));
    }
  }
}
