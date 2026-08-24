// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get scheduleError => 'Schedule error';

  @override
  String get schedule => 'Schedule';

  @override
  String get week => 'week';

  @override
  String get now => 'now';

  @override
  String get noSchedule => 'No schedule for this week';

  @override
  String get loadingSchedule => 'Loading schedule';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noLessons => 'No lessons';

  @override
  String get faculty => 'Faculty';

  @override
  String get selectGroup => 'Select group';

  @override
  String get selectFaculty => 'Select faculty';

  @override
  String nCourse(Object n) {
    return '$n course';
  }

  @override
  String get course => 'Course';

  @override
  String get selectCourse => 'Select course';

  @override
  String get selectedGroup => 'Selected group';

  @override
  String get selectAnotherGroup => 'Select another group';

  @override
  String get group => 'Group';

  @override
  String get scheduleApp => 'Uneconly, schedule for SPbSUE';

  @override
  String get options => 'Options';

  @override
  String get searchThreeDots => 'Search...';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get newYearCongratulation => 'Happy New Year!';

  @override
  String get viewScheduleOfAnotherGroup => 'View schedule of another group';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get favoriteGroups => 'Favorite groups';

  @override
  String get addFirstFavoriteGroup =>
      'List is empty. Add groups to favorites to access it quickly';

  @override
  String get add => 'Add';

  @override
  String get noScheduleDescription =>
      'Swipe left to see the schedule for the next week or right to see the schedule for the previous week';

  @override
  String get licenses => 'Licenses';

  @override
  String get showLicenses => 'View licenses list';

  @override
  String get appVersion => 'App version';

  @override
  String get cache => 'Cache';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get cacheIsCleared => 'Cache is successfully cleared!';

  @override
  String get errorWhileCleaningCache =>
      'Unexpected error happened during cache clean. Try again later';

  @override
  String get cacheIsEmpty => 'Cache is empty. Nothing to clean!';

  @override
  String get share => 'Share';

  @override
  String get lastWeekOfCurrentStudyYear =>
      'This is the last week of current study year. Next study year schedule should be available soon';

  @override
  String get checkOutOfficialWebsiteForPreciseInformation =>
      'Check out official website for precise info';

  @override
  String get openOfficialWebsite => 'Open official website';

  @override
  String get news => 'News';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Try again';

  @override
  String get homeWidget => 'Home widget';

  @override
  String get viewNews => 'View news';

  @override
  String get syncWithCalendar => 'Sync schedule with calendar';

  @override
  String get syncWithCalendarDescription =>
      'Sync schedule with your calendar to get notifications about lessons start';

  @override
  String get syncWithCalendarExperimentalDescription =>
      'В данный момент расписание в календаре обновляется только при открытии приложения. В будущем будет добавлена синхронизация в фоновом режиме';

  @override
  String get openCalendar => 'Открыть календарь';

  @override
  String get calendar => 'Календарь';

  @override
  String get grantCalendarPermission => 'Разрешите доступ к календарю';

  @override
  String get calendarPermissionDescription =>
      'Чтобы синхронизировать расписание с вашим календарем, необходимо предоставить доступ к календарю. Откройте настройки приложения и предоставьте доступ к календарю';

  @override
  String get goToSettings => 'Перейти в настройки';

  @override
  String get freeDay => 'Free day';

  @override
  String lessonsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes',
      one: '$count class',
      zero: 'no classes',
    );
    return '$_temp0';
  }

  @override
  String get currentLesson => 'Now';

  @override
  String subgroupPrompt(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subgroups · Choose yours',
      one: '1 subgroup · Choose yours',
    );
    return '$_temp0';
  }

  @override
  String get yourSubgroup => 'your subgroup';

  @override
  String get professorMissingToday =>
      'Your professor is not in today\'s schedule';

  @override
  String get possibleReplacement =>
      'There may be a replacement — choose an option for this date.';

  @override
  String whoTeachesSubject(Object subject) {
    return 'Who teaches your “$subject” class?';
  }

  @override
  String parallelSubgroupsDescription(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count subgroups run at the same time. Select your professor and the app will keep the room up to date from the schedule.',
      one:
          'This class has multiple published options. Select your professor and the app will keep the room up to date from the schedule.',
    );
    return '$_temp0';
  }

  @override
  String get professorUnknown => 'Professor not specified';

  @override
  String get rememberForSubject => 'Remember for this subject';

  @override
  String onlyOnDate(Object date) {
    return 'Only on $date';
  }

  @override
  String onWeekdays(Object weekday) {
    return 'On $weekday';
  }

  @override
  String get choiceRules => 'Adjust rule';

  @override
  String get hideChoiceRules => 'Hide additional rules';

  @override
  String get saveSubgroup => 'This is my subgroup';

  @override
  String get saving => 'Saving…';

  @override
  String get lessonDetails => 'Class details';

  @override
  String get professorSchedule => 'Professor schedule';

  @override
  String get roomMap => 'Room map';

  @override
  String get changeProfessor => 'Change professor';

  @override
  String lessonType(Object type) {
    return 'Class type: $type';
  }
}
