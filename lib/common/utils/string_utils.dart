String capitalize(String s) {
  return "${s[0].toUpperCase()}${s.substring(1).toLowerCase()}";
}

String trimSeparators(String s) {
  final sWithoutNewLines = s.replaceAll('\n', ' ');

  final splitted = sWithoutNewLines.split(' ').where((e) => e.isNotEmpty);

  return splitted.map((e) => e.trim()).join(' ');
}
