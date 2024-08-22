import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/routing/routes.dart';

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
      appBar: AppBar(),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} // LoadingPage
