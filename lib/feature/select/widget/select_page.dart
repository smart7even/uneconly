import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uneconly/common/routing/app_route_path.dart';
import 'package:uneconly/common/routing/app_router.dart';
import 'package:uneconly/constants.dart';
import 'package:uneconly/feature/select/bloc/group_bloc.dart';
import 'package:uneconly/feature/select/data/group_network_data_provider.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';

/// {@template select_page}
/// SelectPage widget
/// {@endtemplate}
class SelectPage extends StatefulWidget {
  /// {@macro select_page}
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
} // SelectPage

/// State for widget SelectPage
class _SelectPageState extends State<SelectPage> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void didUpdateWidget(SelectPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget configuration changed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The configuration of InheritedWidgets has changed
    // Also called after initState but before build
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  void onPressed(int groupId, String groupName) {
    AppRouter.navigate(
      context,
      (configuration) => AppRoutePath.schedule(
        groupId: groupId,
        groupName: groupName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = GroupBloc(
          groupRepository: GroupRepository(
            networkDataProvider: GroupNetworkDataProvider(
              dio: Dio(
                BaseOptions(
                  baseUrl: serverAddress,
                ),
              ),
            ),
          ),
        );
        bloc.add(
          const GroupEvent.intiial(),
        );

        return bloc;
      },
      child: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('SelectPage'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.groups.length,
                    itemBuilder: (context, index) {
                      final group = state.groups[index];

                      return ListTile(
                        title: Text(group.name),
                        onTap: () => onPressed(
                          group.id,
                          group.name,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} // _SelectPageState
