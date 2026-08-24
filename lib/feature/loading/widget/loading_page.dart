import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/theme/app_theme.dart';

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
    Octopus.of(context).setState((state) {
      return state
        ..removeWhere((state) => true)
        ..add(
          Routes.home.node(),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
          itemCount: 8,
          itemBuilder: (_, index) => Container(
            height: index == 0 ? 32 : (index % 3 == 0 ? 22 : 66),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: context.palette.nestedSurface,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
} // LoadingPage
