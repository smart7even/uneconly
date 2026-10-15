/// Public routing policy. The DSN is an ingestion address, never an API token.
class TelemetryConfig {
  // Used before the first remote response, including an offline first launch.
  // A cached explicit policy still takes precedence (including `off`).
  static const startupSentryDsn = String.fromEnvironment(
    'SENTRY_STARTUP_DSN',
    defaultValue:
        'https://81ead9a721d9eae25f08c45b1f0ef00c@sentry.roadmapik.com/2',
  );
  const TelemetryConfig({
    this.mode = 'both',
    this.sentryDsn = startupSentryDsn,
  });
  final String mode;
  final String sentryDsn;
  bool get appmetrica => mode == 'appmetrica' || mode == 'both';
  bool get sentry => mode == 'sentry' || mode == 'both';

  factory TelemetryConfig.parse(Object? value) {
    if (value == null) return const TelemetryConfig();
    if (value is! Map ||
        !const {
          'appmetrica',
          'sentry',
          'both',
          'off',
        }.contains(value['mode'])) {
      throw const FormatException('Invalid telemetry mode');
    }
    final dsn = value['sentry_dsn'] ?? '';
    if (dsn is! String) throw const FormatException('Invalid Sentry DSN');
    final result = TelemetryConfig(
      mode: value['mode'] as String,
      sentryDsn: dsn,
    );
    if (result.sentry) {
      final uri = Uri.tryParse(dsn);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host != 'sentry.roadmapik.com' ||
          (uri.hasPort && uri.port != 443) ||
          uri.userInfo.isEmpty ||
          uri.userInfo.contains(':') ||
          !RegExp(r'^/[0-9]+$').hasMatch(uri.path) ||
          uri.hasQuery ||
          uri.hasFragment) {
        throw const FormatException('Untrusted Sentry destination');
      }
    }
    return result;
  }
}
