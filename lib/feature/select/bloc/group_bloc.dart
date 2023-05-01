import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';
import 'package:uneconly/feature/select/model/faculty.dart';
import 'package:uneconly/feature/select/model/group.dart';

part 'group_bloc.freezed.dart';
part 'group_bloc.g.dart';

/// GroupEvent data class
@freezed
class GroupEvent with _$GroupEvent {
  const factory GroupEvent.intiial() = _InitialGroupEvent;
  const factory GroupEvent.facultySelected({
    required final Faculty faculty,
  }) = _FacultySelectedGroupEvent;

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
    required final List<Faculty> faculties,
    final int? selectedFacultyId,
  }) = IdleGroupState;

  /// Processing state
  const factory GroupState.processing({
    @Default('Processing') final String message,
    required final List<Group> groups,
    required final List<Faculty> faculties,
    final int? selectedFacultyId,
  }) = ProcessingGroupState;

  /// Successful state
  const factory GroupState.successful({
    @Default('Successful') final String message,
    required final List<Group> groups,
    required final List<Faculty> faculties,
    final int? selectedFacultyId,
  }) = SuccessfulGroupState;

  /// Error state
  const factory GroupState.error({
    @Default('Error') final String message,
    required final List<Group> groups,
    required final List<Faculty> faculties,
    final int? selectedFacultyId,
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
          const GroupState.idle(
            groups: [],
            faculties: [],
          ),
        ) {
    on<GroupEvent>(
      (event, emit) async {
        await event.map(
          intiial: (e) async {
            await _mapInitialToState(e, emit);
          },
          facultySelected: (e) async {
            await _mapFacultySelectedToState(e, emit);
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
      faculties: state.faculties,
      selectedFacultyId: state.selectedFacultyId,
    ));
    try {
      final faculties = await _groupRepository.fetchAllFaculties();
      final groups = await _groupRepository.fetchAll();
      emit(GroupState.successful(
        groups: groups,
        faculties: faculties,
        selectedFacultyId: state.selectedFacultyId,
      ));
    } catch (e) {
      emit(
        GroupState.error(
          groups: state.groups,
          faculties: state.faculties,
          selectedFacultyId: state.selectedFacultyId,
        ),
      );
    } finally {
      emit(
        GroupState.idle(
          groups: state.groups,
          faculties: state.faculties,
          selectedFacultyId: state.selectedFacultyId,
        ),
      );
    }
  }

  Future<void> _mapFacultySelectedToState(
    _FacultySelectedGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      GroupState.idle(
        groups: state.groups,
        faculties: state.faculties,
        selectedFacultyId: event.faculty.id,
      ),
    );
  }
}
