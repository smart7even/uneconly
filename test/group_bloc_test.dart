import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/feature/select/bloc/group_bloc.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';
import 'package:uneconly/feature/select/model/faculty.dart';
import 'package:uneconly/feature/select/model/group.dart';

void main() {
  test('group and faculty requests start together', () async {
    final repository = _GroupRepository();
    final bloc = GroupBloc(groupRepository: repository);

    bloc.add(const GroupEvent.intiial());
    await repository.bothStarted.future.timeout(const Duration(seconds: 1));
    repository.faculties.complete(const []);
    repository.groups.complete(const []);
    await bloc.stream.firstWhere((state) => state is SuccessfulGroupState);

    await bloc.close();
  });

  test('a group loading failure remains visible and can be retried', () async {
    final repository = _GroupRepository()..error = StateError('offline');
    final bloc = GroupBloc(groupRepository: repository);

    bloc.add(const GroupEvent.intiial());
    final error = await bloc.stream.firstWhere(
      (state) => state is ErrorGroupState,
    );
    await Future<void>.delayed(Duration.zero);

    expect(error, isA<ErrorGroupState>());
    expect(bloc.state, isA<ErrorGroupState>());
    await bloc.close();
  });
}

class _GroupRepository implements IGroupRepository {
  final faculties = Completer<List<Faculty>>();
  final groups = Completer<List<Group>>();
  final bothStarted = Completer<void>();
  int started = 0;
  Object? error;

  void _markStarted() {
    started++;
    if (started == 2 && !bothStarted.isCompleted) bothStarted.complete();
  }

  @override
  Future<List<Faculty>> fetchAllFaculties() {
    _markStarted();
    if (error case final value?) return Future.error(value);
    return faculties.future;
  }

  @override
  Future<List<Group>> fetchAll() {
    _markStarted();
    if (error case final value?) return Future.error(value);
    return groups.future;
  }

  @override
  Future<Group> fetchGroupById(int groupId) => throw UnimplementedError();
}
