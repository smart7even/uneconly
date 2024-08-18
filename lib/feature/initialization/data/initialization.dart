import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/common/logging/logging_repository_factory.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/util/error_util.dart';
import 'package:uneconly/feature/initialization/data/initialize_dependencies.dart';

/// Ephemerally initializes the app and prepares it for use.
Future<Dependencies>? _$initializeApp;

/// Initializes the app and prepares it for use.
Future<Dependencies> $initializeApp({
  void Function(int progress, String message)? onProgress,
  FutureOr<void> Function(Dependencies dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
  void Function(ILoggingRepository loggingRepository)?
      onLoggingRepositoryInitialized,
}) =>
    _$initializeApp ??= Future<Dependencies>(() async {
      late final WidgetsBinding binding;
      final stopwatch = Stopwatch()..start();
      ILoggingRepository? loggingRepository;
      try {
        binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
        loggingRepository = await LoggingRepositoryFactory().create();
        onLoggingRepositoryInitialized?.call(loggingRepository);
        await _catchExceptions(loggingRepository);
        final dependencies = await $initializeDependencies(
          onProgress: onProgress,
          loggingRepository: loggingRepository,
        ).timeout(const Duration(minutes: 7));
        await onSuccess?.call(dependencies);

        return dependencies;
      } on Object catch (error, stackTrace) {
        onError?.call(error, stackTrace);
        ErrorUtil.logError(error, stackTrace, hint: 'Failed to initialize app')
            .ignore();
        loggingRepository?.logError(error, stackTrace);
        rethrow;
      } finally {
        stopwatch.stop();
        binding.addPostFrameCallback((_) {
          // Closes splash screen, and show the app layout.
          binding.allowFirstFrame();
          //final context = binding.renderViewElement;
        });
        _$initializeApp = null;
      }
    });

/// Resets the app's state to its initial state.
@visibleForTesting
Future<void> $resetApp(Dependencies dependencies) async {}

/// Disposes the app and releases all resources.
@visibleForTesting
Future<void> $disposeApp(Dependencies dependencies) async {}

Future<void> _catchExceptions(ILoggingRepository loggingRepository) async {
  try {
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      loggingRepository.logError(error, stackTrace);
      ErrorUtil.logError(
        error,
        stackTrace,
        hint: 'ROOT ERROR\r\n${Error.safeToString(error)}',
      ).ignore();

      return true;
    };

    final sourceFlutterError = FlutterError.onError;
    FlutterError.onError = (final details) {
      loggingRepository.logError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
      ErrorUtil.logError(
        details.exception,
        details.stack ?? StackTrace.current,
        hint: 'FLUTTER ERROR\r\n$details',
      ).ignore();
      // FlutterError.presentError(details);
      sourceFlutterError?.call(details);
    };
  } on Object catch (error, stackTrace) {
    ErrorUtil.logError(error, stackTrace).ignore();
  }
}
