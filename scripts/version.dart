import 'dart:convert';

class Version {
  final int major;
  final int minor;
  final int patch;
  final int buildNumber;

  const Version({
    required this.major,
    required this.minor,
    required this.patch,
    required this.buildNumber,
  });

  factory Version.major() {
    return const Version(
      major: 1,
      minor: 0,
      patch: 0,
      buildNumber: 1,
    );
  }

  factory Version.minor() {
    return const Version(
      major: 0,
      minor: 1,
      patch: 0,
      buildNumber: 1,
    );
  }

  factory Version.patch() {
    return const Version(
      major: 0,
      minor: 0,
      patch: 1,
      buildNumber: 1,
    );
  }

  Version operator +(Version other) {
    return Version(
      major: major + other.major,
      minor: minor + other.minor,
      patch: patch + other.patch,
      buildNumber: buildNumber + other.buildNumber,
    );
  }

  factory Version.fromString(String version) {
    final splittedByPlusVersion = version.split('+');

    final primaryVersion = splittedByPlusVersion[0].split('.');
    final buildNumber = splittedByPlusVersion[1];

    return Version(
      major: int.parse(primaryVersion[0]),
      minor: int.parse(primaryVersion[1]),
      patch: int.parse(primaryVersion[2]),
      buildNumber: int.parse(buildNumber),
    );
  }

  @override
  String toString() {
    return 'Version(major: $major, minor: $minor, patch: $patch, buildNumber: $buildNumber)';
  }

  String toVersionString() {
    return '$major.$minor.$patch+$buildNumber';
  }

  Version getNewReleaseVersion(Version releaseType) {
    if (releaseType == Version.major()) {
      return getNewMajorReleaseVersion();
    } else if (releaseType == Version.minor()) {
      return getNewMinorReleaseVersion();
    } else if (releaseType == Version.patch()) {
      return getNewPatchReleaseVersion();
    }

    throw ArgumentError('Invalid release type');
  }

  Version getNewMajorReleaseVersion() {
    return (this + Version.major()).copyWith(
      minor: 0,
      patch: 0,
    );
  }

  Version getNewMinorReleaseVersion() {
    return (this + Version.minor()).copyWith(
      patch: 0,
    );
  }

  Version getNewPatchReleaseVersion() {
    return this + Version.patch();
  }

  Version copyWith({
    int? major,
    int? minor,
    int? patch,
    int? buildNumber,
  }) {
    return Version(
      major: major ?? this.major,
      minor: minor ?? this.minor,
      patch: patch ?? this.patch,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'major': major,
      'minor': minor,
      'patch': patch,
      'buildNumber': buildNumber,
    };
  }

  factory Version.fromMap(Map<String, dynamic> map) {
    return Version(
      major: map['major']?.toInt() ?? 0,
      minor: map['minor']?.toInt() ?? 0,
      patch: map['patch']?.toInt() ?? 0,
      buildNumber: map['buildNumber']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Version.fromJson(String source) =>
      Version.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Version &&
        other.major == major &&
        other.minor == minor &&
        other.patch == patch &&
        other.buildNumber == buildNumber;
  }

  @override
  int get hashCode {
    return major.hashCode ^
        minor.hashCode ^
        patch.hashCode ^
        buildNumber.hashCode;
  }
}
