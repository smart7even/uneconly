import 'package:flutter/material.dart';
import 'package:uneconly/common/routing/app_route_path.dart';
import 'package:uneconly/common/routing/app_router.dart';

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

  void onPressed() {
    AppRouter.navigate(
      context,
      (configuration) => const AppRoutePath.schedule(
        groupId: 12837,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SelectPage'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          child: const Text('Go to SchedulePage'),
        ),
      ),
    );
  }
} // _SelectPageState
