import 'dart:async';

import 'package:octopus/octopus.dart';

Future<void> waitRouteChange(Octopus octopus) async {
  final completer = Completer();

  Future<void> listener() async {
    completer.complete();
  }

  octopus.observer.addListener(listener);

  await completer.future;

  octopus.observer.removeListener(listener);
}
