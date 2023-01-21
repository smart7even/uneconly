import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uneconly/constants.dart';
import 'package:uneconly/feature/schedule/bloc/schedule_bloc.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/data/schedule_repository.dart';

/// {@template schedule_page}
/// SchedulePage widget
/// {@endtemplate}
class SchedulePage extends StatefulWidget {
  /// {@macro schedule_page}
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
} // SchedulePage

/// State for widget SchedulePage
class _SchedulePageState extends State<SchedulePage> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void didUpdateWidget(SchedulePage oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        Dio dio = Dio(BaseOptions(
          baseUrl: serverAddress,
        ));

        ScheduleNetworkDataProvider scheduleNetworkDataProvider =
            ScheduleNetworkDataProvider(
          dio: dio,
        );

        ScheduleRepository repository = ScheduleRepository(
            networkDataProvider: scheduleNetworkDataProvider);

        var bloc = ScheduleBLoC(repository: repository);
        bloc.add(const ScheduleEvent.fetch(groupId: 12837, week: 21));

        return bloc;
      },
      child: BlocBuilder<ScheduleBLoC, ScheduleState>(
        builder: (context, state) {
          return state.when<Widget>(
            idle: (data, message) {
              var schedule = data;

              if (schedule == null) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Schedule idle'),
                  ),
                  body: const Center(
                    child: Text('Schedule'),
                  ),
                );
              }

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Schedule idle'),
                ),
                body: ListView.builder(
                  itemCount: schedule.lessons.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(schedule.lessons[index].name),
                      subtitle: Text(schedule.lessons[index].professor),
                    );
                  },
                ),
              );
            },
            processing: (data, message) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Schedule processing'),
                ),
                body: const Center(
                  child: Text('Schedule'),
                ),
              );
            },
            successful: (data, message) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Schedule successful'),
                ),
                body: const Center(
                  child: Text('Schedule'),
                ),
              );
            },
            error: (data, message) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Schedule error'),
                ),
                body: const Center(
                  child: Text('Schedule'),
                ),
              );
            },
          );
        },
      ),
    );
  }
} // _SchedulePageState
