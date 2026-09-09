import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @scheduleError.
  ///
  /// In en, this message translates to:
  /// **'Schedule error'**
  String get scheduleError;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @noSchedule.
  ///
  /// In en, this message translates to:
  /// **'No schedule for this week'**
  String get noSchedule;

  /// No description provided for @loadingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Loading schedule'**
  String get loadingSchedule;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noLessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons'**
  String get noLessons;

  /// No description provided for @faculty.
  ///
  /// In en, this message translates to:
  /// **'Faculty'**
  String get faculty;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get selectGroup;

  /// No description provided for @selectFaculty.
  ///
  /// In en, this message translates to:
  /// **'Select faculty'**
  String get selectFaculty;

  /// No description provided for @nCourse.
  ///
  /// In en, this message translates to:
  /// **'{n} course'**
  String nCourse(Object n);

  /// No description provided for @course.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get course;

  /// No description provided for @selectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select course'**
  String get selectCourse;

  /// No description provided for @selectedGroup.
  ///
  /// In en, this message translates to:
  /// **'Selected group'**
  String get selectedGroup;

  /// No description provided for @selectAnotherGroup.
  ///
  /// In en, this message translates to:
  /// **'Select another group'**
  String get selectAnotherGroup;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @scheduleApp.
  ///
  /// In en, this message translates to:
  /// **'Uneconly, schedule for SPbSUE'**
  String get scheduleApp;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @searchThreeDots.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchThreeDots;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @newYearCongratulation.
  ///
  /// In en, this message translates to:
  /// **'Happy New Year!'**
  String get newYearCongratulation;

  /// No description provided for @viewScheduleOfAnotherGroup.
  ///
  /// In en, this message translates to:
  /// **'View schedule of another group'**
  String get viewScheduleOfAnotherGroup;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @favoriteGroups.
  ///
  /// In en, this message translates to:
  /// **'Favorite groups'**
  String get favoriteGroups;

  /// No description provided for @addFirstFavoriteGroup.
  ///
  /// In en, this message translates to:
  /// **'List is empty. Add groups to favorites to access it quickly'**
  String get addFirstFavoriteGroup;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noScheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to see the schedule for the next week or right to see the schedule for the previous week'**
  String get noScheduleDescription;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @showLicenses.
  ///
  /// In en, this message translates to:
  /// **'View licenses list'**
  String get showLicenses;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @cacheIsCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache is successfully cleared!'**
  String get cacheIsCleared;

  /// No description provided for @errorWhileCleaningCache.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error happened during cache clean. Try again later'**
  String get errorWhileCleaningCache;

  /// No description provided for @cacheIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cache is empty. Nothing to clean!'**
  String get cacheIsEmpty;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @lastWeekOfCurrentStudyYear.
  ///
  /// In en, this message translates to:
  /// **'This is the last week of current study year. Next study year schedule should be available soon'**
  String get lastWeekOfCurrentStudyYear;

  /// No description provided for @checkOutOfficialWebsiteForPreciseInformation.
  ///
  /// In en, this message translates to:
  /// **'Check out official website for precise info'**
  String get checkOutOfficialWebsiteForPreciseInformation;

  /// No description provided for @openOfficialWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open official website'**
  String get openOfficialWebsite;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @homeWidget.
  ///
  /// In en, this message translates to:
  /// **'Home widget'**
  String get homeWidget;

  /// No description provided for @viewNews.
  ///
  /// In en, this message translates to:
  /// **'View news'**
  String get viewNews;

  /// No description provided for @syncWithCalendar.
  ///
  /// In en, this message translates to:
  /// **'Sync schedule with calendar'**
  String get syncWithCalendar;

  /// No description provided for @syncWithCalendarDescription.
  ///
  /// In en, this message translates to:
  /// **'Sync schedule with your calendar to get notifications about lessons start'**
  String get syncWithCalendarDescription;

  /// No description provided for @syncWithCalendarExperimentalDescription.
  ///
  /// In en, this message translates to:
  /// **'В данный момент расписание в календаре обновляется только при открытии приложения. В будущем будет добавлена синхронизация в фоновом режиме'**
  String get syncWithCalendarExperimentalDescription;

  /// No description provided for @openCalendar.
  ///
  /// In en, this message translates to:
  /// **'Открыть календарь'**
  String get openCalendar;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Календарь'**
  String get calendar;

  /// No description provided for @grantCalendarPermission.
  ///
  /// In en, this message translates to:
  /// **'Разрешите доступ к календарю'**
  String get grantCalendarPermission;

  /// No description provided for @calendarPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Чтобы синхронизировать расписание с вашим календарем, необходимо предоставить доступ к календарю. Откройте настройки приложения и предоставьте доступ к календарю'**
  String get calendarPermissionDescription;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Перейти в настройки'**
  String get goToSettings;

  /// No description provided for @freeDay.
  ///
  /// In en, this message translates to:
  /// **'Free day'**
  String get freeDay;

  /// No description provided for @lessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no classes} one{{count} class} other{{count} classes}}'**
  String lessonsCount(num count);

  /// No description provided for @currentLesson.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get currentLesson;

  /// No description provided for @subgroupPrompt.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 subgroup · Choose yours} other{{count} subgroups · Choose yours}}'**
  String subgroupPrompt(num count);

  /// No description provided for @yourSubgroup.
  ///
  /// In en, this message translates to:
  /// **'your subgroup'**
  String get yourSubgroup;

  /// No description provided for @professorMissingToday.
  ///
  /// In en, this message translates to:
  /// **'Your professor is not in today\'s schedule'**
  String get professorMissingToday;

  /// No description provided for @possibleReplacement.
  ///
  /// In en, this message translates to:
  /// **'There may be a replacement — choose an option for this date.'**
  String get possibleReplacement;

  /// No description provided for @whoTeachesSubject.
  ///
  /// In en, this message translates to:
  /// **'Who teaches your “{subject}” class?'**
  String whoTeachesSubject(Object subject);

  /// No description provided for @parallelSubgroupsDescription.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{This class has multiple published options. Select your professor and the app will keep the room up to date from the schedule.} other{{count} subgroups run at the same time. Select your professor and the app will keep the room up to date from the schedule.}}'**
  String parallelSubgroupsDescription(num count);

  /// No description provided for @professorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Professor not specified'**
  String get professorUnknown;

  /// No description provided for @rememberForSubject.
  ///
  /// In en, this message translates to:
  /// **'Remember for this subject'**
  String get rememberForSubject;

  /// No description provided for @onlyOnDate.
  ///
  /// In en, this message translates to:
  /// **'Only on {date}'**
  String onlyOnDate(Object date);

  /// No description provided for @onWeekdays.
  ///
  /// In en, this message translates to:
  /// **'On {weekday}'**
  String onWeekdays(Object weekday);

  /// No description provided for @choiceRules.
  ///
  /// In en, this message translates to:
  /// **'Adjust rule'**
  String get choiceRules;

  /// No description provided for @hideChoiceRules.
  ///
  /// In en, this message translates to:
  /// **'Hide additional rules'**
  String get hideChoiceRules;

  /// No description provided for @saveSubgroup.
  ///
  /// In en, this message translates to:
  /// **'This is my subgroup'**
  String get saveSubgroup;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @lessonDetails.
  ///
  /// In en, this message translates to:
  /// **'Class details'**
  String get lessonDetails;

  /// No description provided for @professorSchedule.
  ///
  /// In en, this message translates to:
  /// **'Professor schedule'**
  String get professorSchedule;

  /// No description provided for @roomMap.
  ///
  /// In en, this message translates to:
  /// **'Room map'**
  String get roomMap;

  /// No description provided for @changeProfessor.
  ///
  /// In en, this message translates to:
  /// **'Change professor'**
  String get changeProfessor;

  /// No description provided for @lessonType.
  ///
  /// In en, this message translates to:
  /// **'Class type: {type}'**
  String lessonType(Object type);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
