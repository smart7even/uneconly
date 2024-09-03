// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class TutorialEntity {
  final Map<String, dynamic> news;

  TutorialEntity({
    required this.news,
  });

  TutorialEntity copyWith({
    Map<String, dynamic>? news,
  }) {
    return TutorialEntity(
      news: news ?? this.news,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'news': news,
    };
  }

  factory TutorialEntity.fromMap(Map<String, dynamic> map) {
    return TutorialEntity(
      news: Map<String, dynamic>.from(
        (map['news'] as Map<String, dynamic>),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory TutorialEntity.fromJson(String source) =>
      TutorialEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Tutorial(news: $news)';

  @override
  bool operator ==(covariant TutorialEntity other) {
    if (identical(this, other)) return true;

    return mapEquals(other.news, news);
  }

  @override
  int get hashCode => news.hashCode;
}
