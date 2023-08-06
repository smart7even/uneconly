import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/app_scroll_configuration.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/dependencies/dependencies_scope.dart';
import 'package:uneconly/common/routing/app_route_information_parser.dart';
import 'package:uneconly/common/routing/app_router_delegate.dart';
import 'package:uneconly/common/utils/colors_utils.dart';
import 'package:uneconly/constants.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final settingsRepository = SettingsRepository(
    localDataProvider: SettingsLocalDataProvider(
      prefs: prefs,
    ),
  );

  runApp(MyApp(
    settingsRepository: settingsRepository,
  ));
}

class MyApp extends StatefulWidget {
  final ISettingsRepository settingsRepository;

  const MyApp({
    super.key,
    required this.settingsRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppRouterDelegate _routerDelegate;
  late AppRouteInformationParser _routeInformationParser;

  late String locale;
  late String theme;

  late StreamSubscription<String> _languageChangedSubscription;
  late StreamSubscription<String> _themeChangedSubscription;

  @override
  void initState() {
    super.initState();

    _routerDelegate = AppRouterDelegate();
    _routeInformationParser = AppRouteInformationParser();

    final defaultLocale = Platform.localeName;
    locale = defaultLocale.split('_')[0];

    const defaultTheme = 'blue';
    theme = defaultTheme;

    widget.settingsRepository.getLanguage().then(
      (value) {
        if (value != null) {
          setState(() {
            locale = value;
          });
        }
      },
    );

    _languageChangedSubscription = widget.settingsRepository
        .getLanguageChangedStream()
        .listen((newLanguage) {
      setState(() {
        locale = newLanguage;
      });
    });

    widget.settingsRepository.getTheme().then(
      (value) {
        if (value != null) {
          setState(() {
            theme = value;
          });
        }
      },
    );

    _themeChangedSubscription =
        widget.settingsRepository.getThemeChangedStream().listen((newTheme) {
      setState(() {
        theme = newTheme;
      });
    });
  }

  @override
  void dispose() {
    _languageChangedSubscription.cancel();
    _themeChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => DependenciesScope(
        database: MyDatabase(),
        dio: Dio(
          BaseOptions(
            baseUrl: serverAddress,
          ),
        ),
        settingsRepository: widget.settingsRepository,
      ),
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.scheduleApp,
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          primarySwatch: getColorFromString(
            theme,
          ),
        ),
        scrollBehavior: AppScrollBehavior(),
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      ),
    );
  }
}
