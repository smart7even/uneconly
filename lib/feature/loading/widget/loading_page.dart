import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:uneconly/common/dependencies/dependencies_scope.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/routing/app_route_path.dart';
import 'package:uneconly/common/routing/app_router.dart';
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
        context.read<DependenciesScope>().settingsRepository;

    final group = await settingsRepository.getGroup();

    if (!mounted) {
      return;
    }

    if (group == null) {
      AppRouter.navigate(
        context,
        (configuration) => const AppRoutePath.select(),
      );
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
      AppRouter.navigate(
        context,
        (configuration) => AppRoutePath.schedule(
          shortGroupInfo: ShortGroupInfo(
            groupId: group.id,
            groupName: group.name,
          ),
        ),
      );
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
