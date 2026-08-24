import 'dart:async';

import 'package:divkit/divkit.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:url_launcher/url_launcher.dart';

/// {@template uneconly_div_kit_view}
/// UneconlyDivKitView widget
/// {@endtemplate}
class UneconlyDivKitView extends StatelessWidget {
  final Map<String, dynamic> data;

  /// {@macro uneconly_div_kit_view}
  const UneconlyDivKitView({super.key, required this.data});

  @override
  Widget build(BuildContext context) => DivKitView(
        data: DefaultDivKitData.fromJson(
          data,
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
} // UneconlyDivKitView

class HttpUrlHandler extends DivActionHandler {
  @override
  bool canHandle(DivContext context, DivActionModel action) {
    final actionUrl = action.url;
    return actionUrl != null &&
        ['https', 'http'].any((scheme) => actionUrl.scheme == scheme);
  }

  @override
  FutureOr<bool> handleAction(DivContext context, DivActionModel action) async {
    final actionUrl = action.url;
    if (actionUrl == null || !canHandle(context, action)) return false;

    await launchUrl(actionUrl);
    return true;
  }
}

class UneconlyUrlHandler extends DivActionHandler {
  UneconlyUrlHandler({required this.handler});

  final ValueChanged<Uri> handler;

  @override
  bool canHandle(DivContext context, DivActionModel action) {
    final actionUrl = action.url;
    return actionUrl != null && actionUrl.scheme == 'uneconly';
  }

  @override
  FutureOr<bool> handleAction(DivContext context, DivActionModel action) async {
    final actionUrl = action.url;
    if (actionUrl == null || !canHandle(context, action)) return false;

    handler(actionUrl);
    return true;
  }
}

class MyDivkitActionHandler extends DivActionHandler {
  MyDivkitActionHandler({required this.uneconlyUrlHandler});

  final typedHandler = DefaultDivActionHandlerTyped();
  final urlHandler = DefaultDivActionHandlerUrl();
  final httpUrlHandler = HttpUrlHandler();
  final UneconlyUrlHandler uneconlyUrlHandler;

  @override
  bool canHandle(DivContext context, DivActionModel action) {
    try {
      if (typedHandler.canHandle(context, action) ||
          httpUrlHandler.canHandle(context, action) ||
          uneconlyUrlHandler.canHandle(context, action)) {
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
