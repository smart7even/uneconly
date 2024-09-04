import 'dart:convert';
import 'dart:io';

import 'version.dart';

void main(List<String> args) async {
  Version releaseType = switch (args[0]) {
    'major' => Version.major(),
    'minor' => Version.minor(),
    'patch' => Version.patch(),
    _ => Version.patch(),
  };

  await updatePubspecVersion(releaseType);
  await makeCodeGeneration();
  await buildIosApp();
  await pushIosAppToTestFlight();
}

Future<void> buildIosApp() async {
  final result = await Process.start(
    'flutter',
    [
      'build',
      'ipa',
      '--dart-define-from-file=env.json',
    ],
    runInShell: true,
  );

  result.stdout.transform(const Utf8Decoder()).listen((data) {
    print(data);
  });

  result.stderr.transform(const Utf8Decoder()).listen((data) {
    print(data);
  });

  print(await result.exitCode);
}

Future<void> makeCodeGeneration() async {
  final result = await Process.start(
    'make',
    ['generate'],
    runInShell: true,
  );

  result.stdout.transform(const Utf8Decoder()).listen((data) {
    print(data);
  });

  result.stderr.transform(const Utf8Decoder()).listen((data) {
    print(data);
  });

  print(await result.exitCode);
}

Future<void> pushIosAppToTestFlight() async {
  final result = await Process.start(
    'fastlane',
    ['beta'],
    workingDirectory: '${Directory.current.path}${Platform.pathSeparator}ios',
    runInShell: true,
  );

  result.stdout.transform(const Utf8Decoder()).listen((data) {
    print(data);
  });

  result.stderr.transform(const Utf8Decoder()).listen((data) {
    print(data);
  });

  print(await result.exitCode);
}

Future<Version?> updatePubspecVersion(Version releaseType) async {
  final pubspecFile = File('pubspec.yaml');

  final pubspecContent = await pubspecFile.readAsString();

  final version = getVersion(pubspecContent);

  if (version == null) {
    return null;
  }

  final newVersion =
      version.getNewReleaseVersion(releaseType).toVersionString();

  final updatedPubspec = getPubspecWithReplacedVersion(
    pubspecContent,
    newVersion,
  );

  await pubspecFile.writeAsString(updatedPubspec);

  return version;
}

Version? getVersion(String pubspec) {
  final splittedPubspecContent = pubspec.split('\n');

  for (int line = 0; line < splittedPubspecContent.length; line++) {
    final lineContent = splittedPubspecContent[line];

    if (lineContent.startsWith('version:')) {
      final versionString = lineContent.split(':')[1].trim();
      final version = Version.fromString(versionString);

      return version;
    }
  }

  return null;
}

String getPubspecWithReplacedVersion(String pubspec, String version) {
  final splittedPubspecContent = pubspec.split('\n');

  for (int line = 0; line < splittedPubspecContent.length; line++) {
    final lineContent = splittedPubspecContent[line];

    if (lineContent.startsWith('version:')) {
      splittedPubspecContent[line] = 'version: $version';

      return splittedPubspecContent.join('\n');
    }
  }

  return splittedPubspecContent.join('\n');
}
