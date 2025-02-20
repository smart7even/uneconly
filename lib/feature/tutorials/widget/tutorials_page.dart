import 'dart:async';

import 'package:divkit/divkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/feature/tutorials/bloc/tutorial_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// {@template tutorials_page}
/// TutorialsPage widget
/// {@endtemplate}
class TutorialsPage extends StatelessWidget {
  /// {@macro tutorials_page}
  const TutorialsPage({super.key});

  Widget _errorWidget(BuildContext context) {
    // return error message widget and refresh button

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.error,
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<TutorialBLoC>(context).add(
                const TutorialEvent.read(),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.tryAgain,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.news),
      ),
      body: BlocProvider(
        create: (context) => TutorialBLoC(
          repository: Dependencies.of(context).tutorialRepository,
        )..add(
            const TutorialEvent.read(),
          ),
        child: BlocBuilder<TutorialBLoC, TutorialState>(
          builder: (context, state) {
            if (state is ProcessingTutorialState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ErrorTutorialState) {
              return _errorWidget(context);
            }

            if (state.data.news.isEmpty) {
              return _errorWidget(context);
            }

            return DivKitView(
              data: DefaultDivKitData.fromJson(
                state.data.news,
              ),
              actionHandler: MyDivkitActionHandler(
                uneconlyUrlHandler: UneconlyUrlHandler(handler: (uri) {
                  if (uri.host == 'home_widget') {
                    context.octopus.push(
                      Routes.homeWidgetTutorial,
                    );
                  }
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HttpUrlHandler extends DivActionHandler {
  @override
  bool canHandle(DivContext context, DivActionModel action) {
    final actionUrl = action.url;

    if (actionUrl != null &&
        ['https', 'http'].any((scheme) => actionUrl.scheme == scheme)) {
      return true;
    }

    return false;
  }

  @override
  FutureOr<bool> handleAction(DivContext context, DivActionModel action) async {
    final actionUrl = action.url;

    if (actionUrl == null) {
      return false;
    }

    if (!canHandle(context, action)) {
      return false;
    }

    await launchUrl(actionUrl);

    return true;
  }
}

class UneconlyUrlHandler extends DivActionHandler {
  final ValueChanged<Uri> handler;

  UneconlyUrlHandler({
    required this.handler,
  });

  @override
  bool canHandle(DivContext context, DivActionModel action) {
    final actionUrl = action.url;

    if (actionUrl != null &&
        ['uneconly'].any((scheme) => actionUrl.scheme == scheme)) {
      return true;
    }

    return false;
  }

  @override
  FutureOr<bool> handleAction(DivContext context, DivActionModel action) async {
    final actionUrl = action.url;

    if (actionUrl == null) {
      return false;
    }

    if (!canHandle(context, action)) {
      return false;
    }

    handler(actionUrl);

    return true;
  }
}

class MyDivkitActionHandler extends DivActionHandler {
  final typedHandler = DefaultDivActionHandlerTyped();
  final urlHandler = DefaultDivActionHandlerUrl();
  final httpUrlHandler = HttpUrlHandler();
  final UneconlyUrlHandler uneconlyUrlHandler;

  MyDivkitActionHandler({
    required this.uneconlyUrlHandler,
  });

  @override
  bool canHandle(DivContext context, DivActionModel action) {
    try {
      if (typedHandler.canHandle(context, action)) {
        return true;
      }
      if (httpUrlHandler.canHandle(context, action)) {
        return true;
      }
      if (uneconlyUrlHandler.canHandle(context, action)) {
        return true;
      }

      return urlHandler.canHandle(context, action);
    } catch (e, st) {
      logger.error(
        '[div-action] Can\'t CHECK action: $action',
        error: e,
        stackTrace: st,
      );

      return false;
    }
  }

  @override
  FutureOr<bool> handleAction(DivContext context, DivActionModel action) async {
    try {
      if (typedHandler.canHandle(context, action)) {
        return typedHandler.handleAction(context, action);
      }
      if (httpUrlHandler.canHandle(context, action)) {
        return httpUrlHandler.handleAction(context, action);
      }
      if (uneconlyUrlHandler.canHandle(context, action)) {
        return uneconlyUrlHandler.handleAction(context, action);
      }

      return urlHandler.handleAction(context, action);
    } catch (e, st) {
      logger.error(
        '[div-action] Can\'t HANDLE action: $action',
        error: e,
        stackTrace: st,
      );

      return false;
    }
  }
}
