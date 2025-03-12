import 'package:divkit/divkit.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/feature/tutorials/widget/tutorials_page.dart';

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
