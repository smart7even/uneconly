import 'dart:convert';
import 'dart:io';

const _bundleId = 'com.roadmapik.uneconly';
const _evidencePath = '.dart_tool/release_gate.json';

Future<void> main(List<String> arguments) async {
  final options = _GateOptions.parse(arguments);
  final evidenceFile = File(_evidencePath);
  if (evidenceFile.existsSync()) evidenceFile.deleteSync();

  final dirty = await _capture('git', [
    'status',
    '--porcelain',
    '--untracked-files=no',
  ]);
  if (dirty.trim().isNotEmpty) {
    stderr.writeln(
      'Core release gate requires a clean tracked working tree. Commit the '
      'release candidate first.',
    );
    exitCode = 2;
    return;
  }

  final pubspec = File('pubspec.yaml').readAsStringSync();
  final versionMatch = RegExp(
    r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec);
  if (versionMatch == null) {
    throw StateError('pubspec.yaml has no release version and build number.');
  }
  final version = versionMatch.group(1)!;
  final buildNumber = versionMatch.group(2)!;
  final commit = (await _capture('git', ['rev-parse', 'HEAD'])).trim();
  final checks = <Map<String, Object?>>[];

  await _check(checks, 'code_generation', 'make', ['generate']);
  await _check(checks, 'localization_generation', 'make', ['intl']);

  final generatedPubspec = File(
    'lib/common/utils/pubspec.yaml.g.dart',
  ).readAsStringSync();
  if (!generatedPubspec.contains("representation: r'$version+$buildNumber'")) {
    throw StateError('Generated in-app version does not match pubspec.yaml.');
  }
  checks.add({'name': 'generated_version', 'status': 'passed'});

  await _check(checks, 'static_analysis', 'flutter', [
    'analyze',
    '--no-fatal-warnings',
  ]);
  await _check(checks, 'flutter_tests', 'flutter', ['test']);
  await _check(checks, 'android_release_apk', 'flutter', [
    'build',
    'apk',
    '--release',
  ]);

  await _run('adb', [
    '-s',
    options.androidDevice,
    'shell',
    'pm',
    'clear',
    _bundleId,
  ], required: false);
  await _check(checks, 'android_core_smoke', 'flutter', [
    'test',
    'integration_test/core_release_smoke_test.dart',
    '-d',
    options.androidDevice,
  ]);

  await _run('xcrun', [
    'simctl',
    'uninstall',
    options.iosDevice,
    _bundleId,
  ], required: false);
  await _check(checks, 'ios_core_smoke', 'flutter', [
    'test',
    'integration_test/core_release_smoke_test.dart',
    '-d',
    options.iosDevice,
  ]);

  evidenceFile.parent.createSync(recursive: true);
  evidenceFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': 1,
      'version': version,
      'buildNumber': buildNumber,
      'gitCommit': commit,
      'completedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'devices': {'android': options.androidDevice, 'ios': options.iosDevice},
      'checks': checks,
    }),
  );

  stdout.writeln('\nCore release gate passed for $version ($buildNumber).');
  stdout.writeln('Evidence: ${evidenceFile.absolute.path}');
}

Future<void> _check(
  List<Map<String, Object?>> checks,
  String name,
  String executable,
  List<String> arguments,
) async {
  final startedAt = DateTime.now();
  await _run(executable, arguments);
  checks.add({
    'name': name,
    'status': 'passed',
    'durationSeconds': DateTime.now().difference(startedAt).inSeconds,
  });
}

Future<void> _run(
  String executable,
  List<String> arguments, {
  bool required = true,
}) async {
  stdout.writeln('\n> $executable ${arguments.join(' ')}');
  final process = await Process.start(executable, arguments);
  final output = stdout.addStream(process.stdout);
  final errors = stderr.addStream(process.stderr);
  final result = await process.exitCode;
  await Future.wait([output, errors]);
  if (required && result != 0) {
    throw ProcessException(
      executable,
      arguments,
      'Exited with $result',
      result,
    );
  }
}

Future<String> _capture(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) {
    throw ProcessException(
      executable,
      arguments,
      result.stderr.toString(),
      result.exitCode,
    );
  }
  return result.stdout.toString();
}

class _GateOptions {
  const _GateOptions({required this.androidDevice, required this.iosDevice});

  final String androidDevice;
  final String iosDevice;

  static _GateOptions parse(List<String> arguments) {
    String? valueAfter(String flag) {
      final index = arguments.indexOf(flag);
      if (index < 0 || index + 1 >= arguments.length) return null;
      return arguments[index + 1];
    }

    final android = valueAfter('--android-device');
    final ios = valueAfter('--ios-device');
    if (android == null || android.isEmpty || ios == null || ios.isEmpty) {
      stderr.writeln(
        'Usage: dart run scripts/core_release_gate.dart '
        '--android-device <device-id> --ios-device <simulator-uuid>',
      );
      exit(64);
    }
    return _GateOptions(androidDevice: android, iosDevice: ios);
  }
}
