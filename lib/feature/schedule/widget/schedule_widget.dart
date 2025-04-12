import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/common/widget/app_button.dart';
import 'package:uneconly/feature/calendar/calendar_block.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/widget/day_schedule_page.dart';
import 'package:uneconly/feature/schedule/widget/lesson_tile.dart';
import 'package:uneconly/feature/schedule/widget/schedule_widget_content.dart';
import 'package:url_launcher/url_launcher.dart';

/// {@template schedule_widget}
/// ScheduleWidget widget
/// {@endtemplate}
class ScheduleWidget extends StatelessWidget {
  final Schedule? schedule;
  final VoidCallback? onNextWeek;
  final VoidCallback? onPreviousWeek;
  final bool showCalendarBlock;
  final VoidCallback onUpdate;

  /// {@macro schedule_widget}
  const ScheduleWidget({
    super.key,
    required this.schedule,
    this.onNextWeek,
    this.onPreviousWeek,
    required this.showCalendarBlock,
    required this.onUpdate,
  });

  List<Widget> _buildSchedule(BuildContext context) {
    List<Widget> slivers = [];

    final currentSchedule = schedule;

    if (currentSchedule == null) {
      slivers.add(
        SliverToBoxAdapter(
          child: ListTile(
            title: Text('${AppLocalizations.of(context)!.loadingSchedule}...'),
          ),
        ),
      );

      return slivers;
    }

    final today = DateTime.now();

    for (var daySchedule in currentSchedule.daySchedules) {
      String sectionTitle = capitalize(
        DateFormat('EEEE, d MMMM', 'ru').format(
          daySchedule.day,
        ),
      );

      final difference = calculateDifferenceInDays(daySchedule.day, today);

      if (difference == 0) {
        sectionTitle = '${AppLocalizations.of(context)!.today}, $sectionTitle';
      } else if (difference == 1) {
        sectionTitle =
            '${AppLocalizations.of(context)!.tomorrow}, $sectionTitle';
      } else if (difference == -1) {
        sectionTitle =
            '${AppLocalizations.of(context)!.yesterday}, $sectionTitle';
      }

      slivers.add(
        SliverToBoxAdapter(
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    sectionTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: difference == 0
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                  ),
                ),
                IconButton(
                  // padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.open_in_new,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return DaySchedulePage(daySchedule: daySchedule);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      if (daySchedule.lessons.isEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(AppLocalizations.of(context)!.noLessons),
            ),
          ),
        );
      } else {
        slivers.add(SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final lesson = daySchedule.lessons[index];

              return LessonTile(
                lesson: lesson,
                currentTime: today,
              );
            },
            childCount: daySchedule.lessons.length,
          ),
        ));
      }

      // Check that day is the last day before new year
      if (daySchedule.day.month == 12 && daySchedule.day.day == 31) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ListTile(
                title: Text(
                  '${AppLocalizations.of(context)!.newYearCongratulation} 🎄',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    slivers.add(
      SliverToBoxAdapter(
        child: ScheduleWidgetContent(
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: AppButton(
              title: context.string.viewNews,
              onPressed: () {
                context.octopus.push(
                  Routes.tutorials,
                );
              },
            ),
          ),
        ),
      ),
    );

    if (showCalendarBlock) {
      slivers.add(
        SliverToBoxAdapter(
          child: ScheduleWidgetContent(
            child: CalendarBlock(
              onChanged: (value) {
                if (value) {
                  onUpdate();
                }
              },
            ),
          ),
        ),
      );
    }

    slivers.add(
      SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).padding.bottom,
        ),
      ),
    );

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final currentSchedule = schedule;

    if (currentSchedule == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.schedule),
      );
    }

    if (currentSchedule.daySchedules.isEmpty) {
      final dateFormat = DateFormat(
        'dd MMMM yyyy',
      );
      final currentTime = DateTime.now();
      final weekStart = dateFormat.format(
        getStartOfStudyWeek(
          currentSchedule.week,
          currentTime,
        ),
      );
      final weekEnd = dateFormat.format(
        getEndOfStudyWeek(
          currentSchedule.week,
          currentTime,
        ),
      );

      final isLastStudyWeekOfCurrentYear = currentSchedule.week == 52;

      if (isLastStudyWeekOfCurrentYear) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 0,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    const Text(
                      '🍀',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 100,
                      ),
                    ),
                    Text('$weekStart - $weekEnd'),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      AppLocalizations.of(context)!.lastWeekOfCurrentStudyYear,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      AppLocalizations.of(context)!
                          .checkOutOfficialWebsiteForPreciseInformation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // TODO: add error handling and make proper setup checking canLaunchUrl before opening url
                        await currentSchedule.info.map(
                          group: (group) async {
                            await launchUrl(
                              Uri.parse(
                                'https://rasp.unecon.ru/raspisanie_grp.php?g=${group.shortGroupInfo.groupId}',
                              ),
                            );
                          },
                          professor: (professor) {},
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.openOfficialWebsite,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.noSchedule),
            Text('$weekStart - $weekEnd'),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context)!.noScheduleDescription,
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onPreviousWeek?.call();
                  },
                  child: const Icon(
                    Icons.arrow_left,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    onNextWeek?.call();
                  },
                  child: const Icon(
                    Icons.arrow_right,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: _buildSchedule(context),
    );
  }
}
