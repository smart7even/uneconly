// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get helloWorld => 'Привет Мир!';

  @override
  String get scheduleError => 'Ошибка загрузки расписания';

  @override
  String get schedule => 'Расписание';

  @override
  String get week => 'неделя';

  @override
  String get now => 'сейчас';

  @override
  String get noSchedule => 'Нет расписания на эту неделю';

  @override
  String get loadingSchedule => 'Загружаем расписание';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get yesterday => 'Вчера';

  @override
  String get noLessons => 'Нет пар';

  @override
  String get faculty => 'Факультет';

  @override
  String get selectGroup => 'Выберите группу';

  @override
  String get selectFaculty => 'Выберите факультет';

  @override
  String nCourse(Object n) {
    return '$n курс';
  }

  @override
  String get course => 'Курс';

  @override
  String get selectCourse => 'Выберите курс';

  @override
  String get selectedGroup => 'Выбранная группа';

  @override
  String get selectAnotherGroup => 'Выбрать другую группу';

  @override
  String get group => 'Группа';

  @override
  String get scheduleApp => 'Uneconly, расписание для СПбГЭУ';

  @override
  String get options => 'Опции';

  @override
  String get searchThreeDots => 'Поиск...';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get system => 'Системная';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Темная';

  @override
  String get newYearCongratulation => 'С Новым Годом!';

  @override
  String get viewScheduleOfAnotherGroup =>
      'Посмотреть расписание другой группы';

  @override
  String get addToFavorites => 'Добавить в избранное';

  @override
  String get removeFromFavorites => 'Удалить из избранного';

  @override
  String get favoriteGroups => 'Избранные группы';

  @override
  String get addFirstFavoriteGroup =>
      'Список пуст. Добавляйте группы в избранное, чтобы быстро получать к ним доступ';

  @override
  String get add => 'Добавить';

  @override
  String get noScheduleDescription =>
      'Свайпните влево, чтобы посмотреть расписание на следующую неделю, или вправо, чтобы посмотреть на предыдущую';

  @override
  String get licenses => 'Лицензии';

  @override
  String get showLicenses => 'Посмотреть список лицензий';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get cache => 'Кэш';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get cacheIsCleared => 'Кэш успешно очищен!';

  @override
  String get errorWhileCleaningCache =>
      'Возникла неожиданная ошибка при очистке кэша. Попробуйте снова';

  @override
  String get cacheIsEmpty => 'Кэш уже пуст!';

  @override
  String get share => 'Поделиться';

  @override
  String get lastWeekOfCurrentStudyYear =>
      'Это последняя неделя текущего учебного года. Скоро должно появиться расписание для следующего учебного года';

  @override
  String get checkOutOfficialWebsiteForPreciseInformation =>
      'Проверяйте точную информацию на официальном веб-сайте';

  @override
  String get openOfficialWebsite => 'Открыть официальный вебсайт';

  @override
  String get news => 'Новости';

  @override
  String get error => 'Ошибка';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get homeWidget => 'Виджет на главном экране';

  @override
  String get viewNews => 'Посмотреть новости';

  @override
  String get syncWithCalendar => 'Добавлять расписание в календарь';

  @override
  String get syncWithCalendarDescription =>
      'Синхронизируйте расписание с вашим календарем, чтобы планировать свою неделю и получать уведомления о начале пар';

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
      'Чтобы синхронизировать расписание с вашим календарем, необходимо предоставить Uneconly доступ к календарю. Перейдите в настройки приложения и предоставьте доступ к календарю, если хотите использовать эту функцию';

  @override
  String get goToSettings => 'Перейти в настройки';

  @override
  String get freeDay => 'Свободный день';

  @override
  String lessonsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пары',
      many: '$count пар',
      few: '$count пары',
      one: '$count пара',
      zero: 'нет пар',
    );
    return '$_temp0';
  }

  @override
  String get currentLesson => 'Сейчас';

  @override
  String subgroupPrompt(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подгруппы · Выберите свою',
      many: '$count подгрупп · Выберите свою',
      few: '$count подгруппы · Выберите свою',
      one: '1 подгруппа · Выберите свою',
    );
    return '$_temp0';
  }

  @override
  String get yourSubgroup => 'ваша подгруппа';

  @override
  String get professorMissingToday =>
      'Вашего преподавателя сегодня нет в расписании';

  @override
  String get possibleReplacement =>
      'Возможна замена — выберите вариант на этот день.';

  @override
  String whoTeachesSubject(Object subject) {
    return 'Кто ведёт у вас «$subject»?';
  }

  @override
  String parallelSubgroupsDescription(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count подгрупп идут одновременно. Отметьте своего преподавателя — аудиторию приложение возьмёт из расписания.',
      one:
          'Занятие опубликовано в нескольких вариантах. Отметьте своего преподавателя — аудиторию приложение возьмёт из расписания.',
    );
    return '$_temp0';
  }

  @override
  String get professorUnknown => 'Преподаватель не указан';

  @override
  String get rememberForSubject => 'Запомнить для этого предмета';

  @override
  String onlyOnDate(Object date) {
    return 'Только $date';
  }

  @override
  String onWeekdays(Object weekday) {
    return 'По $weekday';
  }

  @override
  String get choiceRules => 'Настроить правило';

  @override
  String get hideChoiceRules => 'Скрыть дополнительные правила';

  @override
  String get saveSubgroup => 'Это моя подгруппа';

  @override
  String get saving => 'Сохраняем…';

  @override
  String get lessonDetails => 'О занятии';

  @override
  String get professorSchedule => 'Расписание преподавателя';

  @override
  String get roomMap => 'Схема аудитории';

  @override
  String get changeProfessor => 'Сменить преподавателя';

  @override
  String lessonType(Object type) {
    return 'Тип занятия: $type';
  }
}
