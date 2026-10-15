import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/feature/schedule/model/schedule_details.dart';

/// Extra scroll extent kept below the schedule so its final controls can always
/// be moved above the refresh card. This space is intentionally permanent: the
/// schedule must not jump when the transient overlay appears or disappears.
const double scheduleRefreshOverlayClearance = 96;

class ScheduleRefreshOverlay extends StatefulWidget {
  const ScheduleRefreshOverlay({
    super.key,
    required this.isVisible,
    required this.details,
    this.hasError = false,
    this.hasSucceeded = false,
    this.onRetry,
  });

  final bool isVisible;
  final ScheduleDetails? details;
  final bool hasError;
  final bool hasSucceeded;
  final VoidCallback? onRetry;

  @override
  State<ScheduleRefreshOverlay> createState() => _ScheduleRefreshOverlayState();
}

class _ScheduleRefreshOverlayState extends State<ScheduleRefreshOverlay> {
  late bool _hasError = widget.hasError;

  @override
  void didUpdateWidget(covariant ScheduleRefreshOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A retry/cache hit or a week swipe does not prove recovery. Keep the
    // failure visible until the BLoC publishes a successful network response.
    if (widget.hasError) _hasError = true;
    if (widget.hasSucceeded) _hasError = false;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            reverseDuration: const Duration(milliseconds: 140),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _hasError || (widget.isVisible && widget.details != null)
                ? _ScheduleRefreshCard(
                    key: const ValueKey('schedule-refresh-card'),
                    details: widget.details,
                    hasError: _hasError,
                    onRetry: widget.isVisible ? null : widget.onRetry,
                  )
                : const SizedBox(key: ValueKey('schedule-refresh-placeholder')),
          ),
        ),
      ),
    );
  }
}

class _ScheduleRefreshCard extends StatelessWidget {
  const _ScheduleRefreshCard({
    super.key,
    required this.details,
    required this.hasError,
    required this.onRetry,
  });

  final ScheduleDetails? details;
  final bool hasError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final updatedAt = details?.updatedAt;
    final updatedLabel = updatedAt == null
        ? null
        : DateFormat('d MMM, HH:mm', 'ru').format(updatedAt);
    final subtitle = details != null && (details!.isLocal || hasError)
        ? [
            'Показана сохранённая копия',
            if (updatedLabel != null) 'от $updatedLabel',
          ].join(' · ')
        : null;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Material(
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        color: context.palette.nestedSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: context.palette.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasError)
                Icon(
                  Icons.cloud_off_outlined,
                  size: 18,
                  color: context.palette.muted,
                )
              else
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.palette.accent,
                  ),
                ),
              const SizedBox(width: 11),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasError
                          ? 'Не удалось обновить расписание'
                          : 'Обновляем расписание…',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasError)
                TextButton(onPressed: onRetry, child: const Text('Повторить')),
            ],
          ),
        ),
      ),
    );
  }
}
