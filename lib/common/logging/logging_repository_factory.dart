import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/constants.dart';

abstract class ILoggingRepositoryFactory {
  Future<ILoggingRepository> create();
}

class LoggingRepositoryFactory implements ILoggingRepositoryFactory {
  @override
  Future<ILoggingRepository> create() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await AppMetrica.activate(
        kDebugMode
            ? const AppMetricaConfig(appMetricaDevKey)
            : const AppMetricaConfig(appMetricaProductionKey),
      );

      return AppMetricaLoggingRepository();
    }

    return LocalLoggingRepository();
  }
}
