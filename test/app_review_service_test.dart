import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/common/review/app_review_service.dart';

void main() {
  late SharedPreferences preferences;
  late _FakeReviewGateway gateway;
  late _FakeLoggingRepository logging;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    gateway = _FakeReviewGateway();
    logging = _FakeLoggingRepository();
  });

  AppReviewService service(DateTime now) => AppReviewService(
    preferences: preferences,
    loggingRepository: logging,
    gateway: gateway,
    now: () => now,
  );

  test(
    'requests a native review only after five useful app sessions',
    () async {
      final now = DateTime(2026, 9, 15);

      for (var session = 1; session < 5; session++) {
        final didRequest = await service(
          now.add(Duration(days: session)),
        ).registerSuccessfulScheduleSession();
        expect(didRequest, isFalse);
      }

      final fifth = service(now.add(const Duration(days: 5)));
      expect(await fifth.registerSuccessfulScheduleSession(), isTrue);
      expect(await fifth.registerSuccessfulScheduleSession(), isFalse);
      expect(gateway.requestCalls, 1);
      expect(logging.events.single.$1, 'feedback/review_requested');
      expect(logging.events.single.$2, {'source': 'automatic'});
    },
  );

  test('respects the review cooldown across later sessions', () async {
    final now = DateTime(2026, 1, 1);
    for (var session = 0; session < 5; session++) {
      await service(now).registerSuccessfulScheduleSession();
    }
    expect(gateway.requestCalls, 1);

    for (var session = 0; session < 5; session++) {
      await service(
        now.add(const Duration(days: 30)),
      ).registerSuccessfulScheduleSession();
    }
    expect(gateway.requestCalls, 1);

    for (var session = 0; session < 5; session++) {
      await service(
        now.add(const Duration(days: 181)),
      ).registerSuccessfulScheduleSession();
    }
    expect(gateway.requestCalls, 2);
  });

  test('settings opens the permanent store review screen', () async {
    final didOpen = await service(DateTime(2026, 9, 15)).openStoreReview();

    expect(didOpen, isTrue);
    expect(gateway.openCalls, 1);
    expect(gateway.lastAppStoreId, AppReviewService.appStoreId);
    expect(logging.events.single.$1, 'feedback/store_review_opened');
    expect(logging.events.single.$2, {'source': 'settings'});
  });

  test('store failures stay non-fatal and are logged', () async {
    gateway.openError = StateError('store unavailable');

    expect(await service(DateTime(2026, 9, 15)).openStoreReview(), isFalse);
    expect(logging.errors.single, isA<StateError>());
  });
}

class _FakeReviewGateway implements IAppReviewGateway {
  bool available = true;
  int requestCalls = 0;
  int openCalls = 0;
  String? lastAppStoreId;
  Object? openError;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    requestCalls++;
  }

  @override
  Future<void> openStoreListing({required String appStoreId}) async {
    if (openError case final error?) throw error;
    openCalls++;
    lastAppStoreId = appStoreId;
  }
}

class _FakeLoggingRepository implements ILoggingRepository {
  final errors = <Object>[];
  final events = <(String, Map<String, Object>?)>[];

  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {
    errors.add(exception);
  }

  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {
    events.add((eventName, attributes));
  }
}
