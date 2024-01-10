import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';

/// {@template loading_page}
/// LoadingPage widget
/// {@endtemplate}
class LoadingPage extends StatefulWidget {
  final bool isActive;

  /// {@macro loading_page}
  const LoadingPage({
    super.key,
    required this.isActive,
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.isActive) {
      onOpen();
    }
  }

  @override
  void didUpdateWidget(LoadingPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive) {
      onOpen();
    }
  }

  Future<void> onOpen() async {
    ISettingsRepository settingsRepository =
        Dependencies.of(context).settingsRepository;

    final group = await settingsRepository.getGroup();

    if (!mounted) {
      return;
    }

    if (group == null) {
      Octopus.of(context).setState((state) {
        return state
          ..removeByName(Routes.loading.name)
          ..add(
            Routes.select.node(),
          );
      });
    } else {
      HomeWidget.saveWidgetData<int>(
        'groupId',
        group.id,
      ).then((value) {
        HomeWidget.updateWidget(
          name: 'UWidget',
          iOSName: 'UWidget',
        );
      });

      Octopus.of(context).setState((state) {
        return state
          ..removeByName(Routes.loading.name)
          ..add(
            Routes.schedule.node(
              arguments: <String, String>{
                'groupId': group.id.toString(),
                'groupName': group.name,
              },
            ),
          );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} // LoadingPage
