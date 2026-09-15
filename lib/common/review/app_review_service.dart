import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/logging/logging_repository.dart';

enum AppReviewSource { automatic, settings }

abstract interface class IAppReviewGateway {
  Future<bool> isAvailable();
  Future<void> requestReview();
  Future<void> openStoreListing({required String appStoreId});
}

class AppReviewGateway implements IAppReviewGateway {
  AppReviewGateway({InAppReview? review})
    : _review = review ?? InAppReview.instance;

  final InAppReview _review;

  @override
  Future<bool> isAvailable() => _review.isAvailable();

  @override
  Future<void> requestReview() => _review.requestReview();

  @override
  Future<void> openStoreListing({required String appStoreId}) =>
      _review.openStoreListing(appStoreId: appStoreId);
}

class AppReviewService {
  AppReviewService({
    required SharedPreferences preferences,
    required ILoggingRepository loggingRepository,
    IAppReviewGateway? gateway,
    DateTime Function()? now,
  }) : _preferences = preferences,
       _loggingRepository = loggingRepository,
       _gateway = gateway ?? AppReviewGateway(),
       _now = now ?? DateTime.now;

  static const appStoreId = '6448684369';
  static const qualifyingSessionCount = 5;
  static const requestCooldown = Duration(days: 180);

  static const _sessionCountKey = 'app_review_successful_schedule_sessions';
  static const _lastRequestKey = 'app_review_last_request_at';

  final SharedPreferences _preferences;
  final ILoggingRepository _loggingRepository;
  final IAppReviewGateway _gateway;
  final DateTime Function() _now;

  bool _registeredThisSession = false;

  /// Records one useful home-schedule session per process and, after enough
  /// successful sessions, asks the platform for its quota-controlled review UI.
  Future<bool> registerSuccessfulScheduleSession() async {
    if (_registeredThisSession) return false;
    _registeredThisSession = true;

    final sessions = (_preferences.getInt(_sessionCountKey) ?? 0) + 1;
    await _preferences.setInt(_sessionCountKey, sessions);

    final lastRequestMilliseconds = _preferences.getInt(_lastRequestKey);
    if (sessions < qualifyingSessionCount ||
        (lastRequestMilliseconds != null &&
            _now().difference(
                  DateTime.fromMillisecondsSinceEpoch(lastRequestMilliseconds),
                ) <
                requestCooldown)) {
      return false;
    }

    try {
      if (!await _gateway.isAvailable()) return false;
      await _gateway.requestReview();
      await _markRequested();
      await _loggingRepository.logEvent('feedback/review_requested', {
        'source': AppReviewSource.automatic.name,
      });
      return true;
    } on Object catch (error, stackTrace) {
      await _loggingRepository.logError(
        error,
        stackTrace,
        hint: 'Unable to request an in-app review',
      );
      return false;
    }
  }

  /// Opens the permanent store review screen. Unlike the native prompt, this
  /// path is user-initiated and remains available in Settings at any time.
  Future<bool> openStoreReview({
    AppReviewSource source = AppReviewSource.settings,
  }) async {
    try {
      await _gateway.openStoreListing(appStoreId: appStoreId);
      await _markRequested();
      await _loggingRepository.logEvent('feedback/store_review_opened', {
        'source': source.name,
      });
      return true;
    } on Object catch (error, stackTrace) {
      await _loggingRepository.logError(
        error,
        stackTrace,
        hint: 'Unable to open the store review screen',
      );
      return false;
    }
  }

  Future<void> _markRequested() async {
    await Future.wait([
      _preferences.setInt(_sessionCountKey, 0),
      _preferences.setInt(_lastRequestKey, _now().millisecondsSinceEpoch),
    ]);
  }
}
