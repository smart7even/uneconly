import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:l/l.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/app_scroll_configuration.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/util/error_util.dart';
import 'package:uneconly/common/utils/colors_utils.dart';
import 'package:uneconly/common/widget/app_error.dart';
import 'package:uneconly/feature/initialization/data/initialization.dart';
import 'package:uneconly/feature/initialization/widget/inherited_dependencies.dart';

void main() async {
  l.capture<void>(
    () => runZonedGuarded<void>(
      () async {
        // Splash screen
        final initializationProgress =
            ValueNotifier<({int progress, String message})>(
          (progress: 0, message: ''),
        );
        $initializeApp(
          onProgress: (progress, message) => initializationProgress.value =
              (progress: progress, message: message),
          onSuccess: (dependencies) => runApp(
            InheritedDependencies(
              dependencies: dependencies,
              child: const MyApp(),
            ),
          ),
          onError: (error, stackTrace) {
            runApp(AppError(error: error));
            ErrorUtil.logError(error, stackTrace).ignore();
          },
        ).ignore();
      },
      l.e,
    ),
    const LogOptions(
      handlePrint: true,
      messageFormatting: _messageFormatting,
      outputInRelease: false,
      printColors: true,
    ),
  );
}

/// Formats the log message.
Object _messageFormatting(Object message, LogLevel logLevel, DateTime now) =>
    '${_timeFormat(now)} | $message';

/// Formats the time.
String _timeFormat(DateTime time) =>
    '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Key builderKey = GlobalKey(); // Disable recreate widget tree
  late final Octopus router;

  late String locale;
  late String theme;

  late StreamSubscription<String> _languageChangedSubscription;
  late StreamSubscription<String> _themeChangedSubscription;

  @override
  void initState() {
    super.initState();
    final dependencies = Dependencies.of(context);

    HomeWidget.setAppGroupId('group.roadmapik.test');

    final defaultLocale = Platform.localeName;
    locale = defaultLocale.split('_')[0];

    const defaultTheme = 'blue';
    theme = defaultTheme;

    dependencies.settingsRepository.getLanguage().then(
      (value) {
        if (value != null) {
          setState(() {
            locale = value;
          });
        }
      },
    );

    _languageChangedSubscription = dependencies.settingsRepository
        .getLanguageChangedStream()
        .listen((newLanguage) {
      setState(() {
        locale = newLanguage;
      });
    });

    dependencies.settingsRepository.getTheme().then(
      (value) {
        if (value != null) {
          setState(() {
            theme = value;
          });
        }
      },
    );

    _themeChangedSubscription = dependencies.settingsRepository
        .getThemeChangedStream()
        .listen((newTheme) {
      setState(() {
        theme = newTheme;
      });
    });

    // Create router.
    router = Octopus(
      routes: Routes.values,
      defaultRoute: Routes.loading,
      guards: <IOctopusGuard>[],
      onError: (error, stackTrace) => log(
        error.toString(),
        error: error,
        stackTrace: stackTrace,
      ),
      /* observers: <NavigatorObserver>[
        HeroController(),
      ], */
    );
  }

  @override
  void dispose() {
    _languageChangedSubscription.cancel();
    _themeChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.scheduleApp,
      locale: const Locale('ru'), // Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: getColorFromString(
          theme,
        ),
        useMaterial3: false,
      ),
      scrollBehavior: AppScrollBehavior(),
      routerConfig: router.config,
      builder: (context, child) {
        return MediaQuery(
          key: builderKey,
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: OctopusTools(
            enable: false,
            octopus: router,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
