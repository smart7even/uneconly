import 'dart:async';

import 'package:octopus/octopus.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/feature/select/model/group.dart';

class ScheduleGuard extends OctopusGuard {
  ScheduleGuard({
    super.refresh,
  });

  @override
  FutureOr<OctopusState> call(
    List<OctopusHistoryEntry> history,
    OctopusState$Mutable state,
    Map<String, Object?> context,
  ) async {
    if (state.children.isEmpty) {
      return OctopusState.fromNodes(
        [
          Routes.home.node(),
        ],
      );
    }

    final firstChild = state.children.first;

    if (![
      Routes.home.name,
      Routes.loading.name,
      Routes.select.name,
    ].contains(firstChild.name)) {
      return OctopusState.fromNodes(
        [
          Routes.home.node(),
          ...state.children,
        ],
      );
    }

    return state;
  }
}
