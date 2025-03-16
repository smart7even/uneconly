import 'package:flutter/material.dart';
import 'package:uneconly/common/analytics/analytics_repository.dart';
import 'package:uneconly/common/model/dependencies.dart';

/// {@template page_logging_wrapper}
/// PageLoggingWrapper widget
/// {@endtemplate}
class PageLoggingWrapper extends StatefulWidget {
  final Widget child;
  final String pageName;
  final Map<String, dynamic> parameters;

  /// {@macro page_logging_wrapper}
  const PageLoggingWrapper({
    super.key,
    required this.child,
    required this.pageName,
    required this.parameters,
  });

  @override
  State<PageLoggingWrapper> createState() => _PageLoggingWrapperState();
} // PageLoggingWrapper

/// State for widget PageLoggingWrapper
class _PageLoggingWrapperState extends State<PageLoggingWrapper> {
  late final IAnalyticsRepository _analyticsRepository;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _analyticsRepository = Dependencies.of(context).analyticsRepository;
    _analyticsRepository.logPageOpen(
      widget.pageName,
      widget.parameters,
    );
  }

  @override
  void dispose() {
    _analyticsRepository.logPageClose(
      widget.pageName,
      widget.parameters,
    );
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => widget.child;
} // _PageLoggingWrapperState
