import 'dart:async';

import 'package:octopus/octopus.dart';

Future<void> waitRouteChange(
  Octopus octopus, {
  bool Function()? shouldStopListen,
}) async {
  final completer = Completer();

  Future<void> listener() async {
    if (shouldStopListen != null && !shouldStopListen()) {
      return;
    }

    completer.complete();
  }

  octopus.observer.addListener(listener);

  await completer.future;

  octopus.observer.removeListener(listener);
}
