import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:uneconly/feature/schedule/domain/schedule_share_document.dart';

/// Draws the complete selected period independently of the scroll position.
class ScheduleShareImageRenderer {
  static const double logicalWidth = 480;
  static const double _padding = 24;
  static const double _contentWidth = logicalWidth - _padding * 2;

  Future<Uint8List> render(ScheduleShareDocument document) async {
    final logicalHeight = _paintDocument(null, document);
    // Keep a busy professor week within a predictable memory/texture budget.
    final scale = math.min(
      2.0,
      math.min(
        14000 / logicalHeight,
        math.sqrt(12000000 / (logicalWidth * logicalHeight)),
      ),
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(scale);
    canvas.drawColor(const Color(0xfff5f8f7), BlendMode.src);
    _paintDocument(canvas, document);
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (logicalWidth * scale).ceil(),
      (logicalHeight * scale).ceil(),
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Could not encode schedule image');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
      picture.dispose();
    }
  }

  double _paintDocument(Canvas? canvas, ScheduleShareDocument document) {
    const ink = Color(0xff183432);
    const accent = Color(0xff087b70);
    const muted = Color(0xff536966);
    const line = Color(0xffdce6e3);
    var y = _padding;

    y += _text(
      canvas,
      document.title.isEmpty ? 'Расписание' : document.title,
      const TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: ink),
      x: _padding,
      y: y,
      width: _contentWidth,
    );
    y += 8;
    y += _text(
      canvas,
      'Неделя ${document.week} · ${document.periodLabel}',
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: accent),
      x: _padding,
      y: y,
      width: _contentWidth,
    );
    y += 21;
    if (canvas != null) {
      canvas.drawLine(
        Offset(_padding, y),
        Offset(logicalWidth - _padding, y),
        Paint()
          ..color = line
          ..strokeWidth = 1,
      );
    }
    y += 20;

    if (document.days.every((day) => day.lessons.isEmpty)) {
      y += _text(
        canvas,
        'Нет расписания на эту неделю',
        const TextStyle(fontSize: 18, color: muted),
        x: _padding,
        y: y,
        width: _contentWidth,
      );
      y += 18;
    } else {
      for (final day in document.days) {
        y += _text(
          canvas,
          '${shareWeekday(day.date)} · ${formatShareDate(day.date)}',
          const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          x: _padding,
          y: y,
          width: _contentWidth,
        );
        y += 11;
        if (day.lessons.isEmpty) {
          y += _text(
            canvas,
            'Нет пар',
            const TextStyle(fontSize: 15, color: muted),
            x: _padding + 13,
            y: y,
            width: _contentWidth - 26,
          );
          y += 18;
          continue;
        }
        for (final lesson in day.lessons) {
          final time =
              '${formatShareTime(lesson.start)}–${formatShareTime(lesson.end)}';
          final detail = [
            if (lesson.type.isNotEmpty) lesson.type,
            if (lesson.detail.isNotEmpty) lesson.detail,
          ].join(' · ');
          final timeHeight = _text(
            null,
            time,
            const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
            x: 0,
            y: 0,
            width: _contentWidth - 30,
          );
          final subjectHeight = _text(
            null,
            lesson.subject,
            const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
            x: 0,
            y: 0,
            width: _contentWidth - 30,
          );
          final detailHeight = detail.isEmpty
              ? 0.0
              : _text(
                  null,
                  detail,
                  TextStyle(
                    fontSize: 14,
                    color: lesson.unresolvedSubgroup
                        ? const Color(0xff9d5a00)
                        : muted,
                  ),
                  x: 0,
                  y: 0,
                  width: _contentWidth - 30,
                );
          final cardHeight =
              28 +
              timeHeight +
              5 +
              subjectHeight +
              (detail.isEmpty ? 0 : 6 + detailHeight);
          if (canvas != null) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(_padding, y, _contentWidth, cardHeight),
                const Radius.circular(13),
              ),
              Paint()..color = Colors.white,
            );
            var textY = y + 14;
            textY += _text(
              canvas,
              time,
              const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
              x: _padding + 15,
              y: textY,
              width: _contentWidth - 30,
            );
            textY += 5;
            textY += _text(
              canvas,
              lesson.subject,
              const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
              x: _padding + 15,
              y: textY,
              width: _contentWidth - 30,
            );
            if (detail.isNotEmpty) {
              _text(
                canvas,
                detail,
                TextStyle(
                  fontSize: 14,
                  color: lesson.unresolvedSubgroup
                      ? const Color(0xff9d5a00)
                      : muted,
                ),
                x: _padding + 15,
                y: textY + 6,
                width: _contentWidth - 30,
              );
            }
          }
          y += cardHeight + 9;
        }
        y += 13;
      }
    }

    if (document.updatedAt != null) {
      y += _text(
        canvas,
        'Данные обновлены ${formatShareDate(document.updatedAt!)} '
        '${formatShareTime(document.updatedAt!)}',
        const TextStyle(fontSize: 13, color: muted),
        x: _padding,
        y: y,
        width: _contentWidth,
      );
      y += 5;
    }
    y += _text(
      canvas,
      'Расписание может измениться · Uneconly',
      const TextStyle(fontSize: 13, color: muted),
      x: _padding,
      y: y,
      width: _contentWidth,
    );
    return y + _padding;
  }

  double _text(
    Canvas? canvas,
    String value,
    TextStyle style, {
    required double x,
    required double y,
    required double width,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    if (canvas != null) painter.paint(canvas, Offset(x, y));
    final height = painter.height;
    painter.dispose();
    return height;
  }
}
