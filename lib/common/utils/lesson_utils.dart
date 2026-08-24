import 'package:uneconly/feature/schedule/model/lesson.dart';

class LessonCluster {
  const LessonCluster(this.alternatives);

  final List<Lesson> alternatives;

  Lesson get lesson => alternatives.first;
  bool get hasAlternatives => alternatives.length > 1;
}

/// Combines source rows that describe subgroup alternatives for the same
/// lesson slot. Professor schedules deliberately opt out because concurrent
/// rows there describe different student groups, not choices for one student.
List<LessonCluster> clusterParallelLessons(
  List<Lesson> lessons, {
  required bool combineAlternatives,
}) {
  if (!combineAlternatives) {
    return lessons.map((lesson) => LessonCluster([lesson])).toList();
  }

  final clusters = <LessonCluster>[];
  for (final lesson in lessons) {
    final index = clusters.indexWhere((cluster) {
      final first = cluster.lesson;
      return first.start == lesson.start &&
          first.end == lesson.end &&
          first.name.trim() == lesson.name.trim();
    });
    if (index == -1) {
      clusters.add(LessonCluster([lesson]));
    } else {
      clusters[index].alternatives.add(lesson);
    }
  }
  clusters.sort((a, b) => a.lesson.start.compareTo(b.lesson.start));
  return clusters;
}

List<List<Lesson>> groupLessonsByTime(List<Lesson> lessons) {
  final groupedLessons = <List<Lesson>>[];

  for (final lesson in lessons) {
    final index = groupedLessons.indexWhere(
      (groupedLesson) => groupedLesson.first.start == lesson.start,
    );

    if (index == -1) {
      groupedLessons.add([lesson]);
    } else {
      groupedLessons[index].add(lesson);
    }
  }

  return groupedLessons;
}

/// Older backend versions flattened the university's room-map button caption
/// into the location. Keep the new client readable during a staggered rollout.
String cleanLessonLocation(
  String location, {
  bool removeMapCaption = true,
}) {
  var result = location;
  if (removeMapCaption) {
    result = result.replaceAll(
      RegExp(
        r'(?:ПОКАЗАТЬ\s+НА\s+СХЕМЕ|(?:НА\s+)?СХЕМЕ\s+(?:ЛИНГВОБАШНИ|АПРАКСИН))',
        caseSensitive: false,
      ),
      '',
    );
  }
  return result.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Shortens a full Russian-style name for the dense week view while retaining
/// the full value in details and semantics.
String compactPersonName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length < 2) return name.trim();

  final initials = parts.skip(1).where((part) => part.isNotEmpty).map(
        (part) => '${part.substring(0, 1).toUpperCase()}.',
      );
  return '${parts.first} ${initials.join(' ')}';
}

/// Normalizes the university room wording for quick scanning. The parser's
/// original location remains untouched and is shown in the lesson details.
String compactLessonLocation(
  String location, {
  bool removeMapCaption = true,
}) {
  var result = cleanLessonLocation(
    location,
    removeMapCaption: removeMapCaption,
  );
  final roomMatch = RegExp(
    r'^(\S+)\s+ауд\.\s*',
    caseSensitive: false,
  ).firstMatch(result);
  if (roomMatch != null) {
    result = 'ауд. ${roomMatch.group(1)} · ${result.substring(roomMatch.end)}';
  }
  result = result.replaceAllMapped(
    RegExp(r'(\d+)\s+лестниц[аы]', caseSensitive: false),
    (match) => 'лестница ${match.group(1)}',
  );
  final staircaseMatch = RegExp(
    r'\s+(лестница\s+\d+)\s*$',
    caseSensitive: false,
  ).firstMatch(result);
  if (staircaseMatch != null) {
    result = '${result.substring(0, staircaseMatch.start)}, '
        '${staircaseMatch.group(1)}';
  }
  return result.replaceAll(RegExp(r'\s+'), ' ').trim();
}
