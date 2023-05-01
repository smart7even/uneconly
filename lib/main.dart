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
import 'package:uneconly/constants.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(
    prefs: prefs,
  ));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.prefs,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppRouterDelegate _routerDelegate;
  late AppRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    _routerDelegate = AppRouterDelegate();
    _routeInformationParser = AppRouteInformationParser();
    super.initState();
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
        settingsRepository: SettingsRepository(
          localDataProvider: SettingsLocalDataProvider(
            prefs: widget.prefs,
          ),
        ),
      ),
      child: MaterialApp.router(
        title: 'Schedule App',
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        scrollBehavior: AppScrollBehavior(),
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      ),
    );
  }
}
