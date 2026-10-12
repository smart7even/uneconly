import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/common/logging/telemetry_identity.dart';
import 'package:uneconly/common/network/client_identity.dart';
import 'package:uneconly/common/network/network_policy.dart';

class RecordingLogger extends LocalLoggingRepository {
  Map<String, Object>? attributes;
  @override
  Future<void> logEvent(String name, [Map<String, Object>? values]) async {
    attributes = values;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  test(
    'installation identity persists and preserves existing Sentry identity',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final id = await installationId(prefs);
      expect(id, matches(RegExp(r'^[a-f0-9]{32}$')));
      expect(await installationId(prefs), id);
      expect(prefs.getString('telemetry.installation_id'), id);
    },
  );

  test(
    'real API requests correlate errors without exporting private payloads',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final external = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = <HttpHeaders>[];
      server.listen((request) async {
        received.add(request.headers);
        request.response.statusCode = 503;
        request.response.write('private server error');
        await request.response.close();
      });
      external.listen((request) async {
        expect(request.headers.value('X-Installation-ID'), isNull);
        expect(request.headers.value('X-App-Version'), isNull);
        await request.response.close();
      });
      final logger = RecordingLogger();
      final dio = createApiClient(baseUrl: 'http://127.0.0.1:${server.port}');
      attachClientIdentity(
        dio,
        version: '2.0.4',
        build: '67',
        platform: 'android',
        installation: 'a' * 32,
        logger: logger,
      );
      try {
        for (var i = 0; i < 2; i++) {
          await expectLater(
            dio.get<dynamic>('/test?secret=private'),
            throwsA(isA<DioException>()),
          );
        }
        expect(
          received.first.value('User-Agent'),
          'Uneconly/2.0.4 (build/67; android)',
        );
        expect(received.first.value('X-App-Version'), '2.0.4');
        expect(received.first.value('X-App-Build'), '67');
        expect(received.first.value('X-App-Platform'), 'android');
        expect(received.first.value('X-Installation-ID'), 'a' * 32);
        expect(
          received.first.value('X-Request-ID'),
          isNot(received.last.value('X-Request-ID')),
        );
        expect(
          logger.attributes!['request_id'],
          received.last.value('X-Request-ID'),
        );
        expect(logger.attributes!['http_status_code'], 503);
        expect(logger.attributes.toString(), isNot(contains('private')));
        await dio.get<dynamic>('http://127.0.0.1:${external.port}/');
      } finally {
        dio.close(force: true);
        await server.close(force: true);
        await external.close(force: true);
      }
    },
  );
}
