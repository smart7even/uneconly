import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uneconly/common/dependencies/dependencies_scope.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/routing/app_route_path.dart';
import 'package:uneconly/common/routing/app_router.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';

/// {@template loading_page}
/// LoadingPage widget
/// {@endtemplate}
class LoadingPage extends StatefulWidget {
  /// {@macro loading_page}
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    onOpen();
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
