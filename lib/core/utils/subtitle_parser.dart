import 'dart:convert';
import 'dart:io';

import '../models/video_file.dart';

/// Parses SRT subtitle files into a list of [SubtitleItem]s.
///
/// Supports standard SRT format with sequence numbers, timecodes
/// (HH:MM:SS,mmm --> HH:MM:SS,mmm), and multi-line text.
class SubtitleParser {
  /// Reads and parses an SRT file from [path].
  static Future<List<SubtitleItem>> parseFile(String path) async {
    final content = await File(path).readAsString(encoding: utf8);
    return parse(content);
  }

  /// Parses raw SRT [content] into a list of [SubtitleItem]s.
  static List<SubtitleItem> parse(String content) {
    // Normalise line endings to \n
    final normalised = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Remove UTF-8 BOM if present
    final cleaned = normalised.startsWith('\uFEFF')
        ? normalised.substring(1)
        : normalised;

    final items = <SubtitleItem>[];

    // Split into blocks separated by blank lines
    final blocks = cleaned.trim().split('\n\n');

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 2) continue;

      // First line should be the sequence number
      final index = int.tryParse(lines[0].trim()) ?? 0;

      // Second line is the timecode: HH:MM:SS,mmm --> HH:MM:SS,mmm
      final timecode = lines[1].trim();
      final arrow = timecode.indexOf('-->');
      if (arrow < 0) continue;

      final startStr = timecode.substring(0, arrow).trim();
      final endStr = timecode.substring(arrow + 3).trim();

      final start = _parseTimestamp(startStr);
      final end = _parseTimestamp(endStr);
      if (start == null || end == null) continue;

      // Remaining lines are the subtitle text
      final textLines = lines.length > 2
          ? lines.sublist(2).join('\n').trim()
          : '';

      items.add(SubtitleItem(
        index: index,
        start: start,
        end: end,
        text: textLines,
      ));
    }

    return items;
  }

  /// Parses a timestamp in the format `HH:MM:SS,mmm` or `HH:MM:SS.mmm`.
  static Duration? _parseTimestamp(String timestamp) {
    final ts = timestamp.trim().replaceAll(',', '.');
    final parts = ts.split(':');
    if (parts.length != 3) return null;

    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;

    final secParts = parts[2].split('.');
    final seconds = int.tryParse(secParts[0]);
    if (seconds == null) return null;

    var milliseconds = 0;
    if (secParts.length > 1) {
      final msStr = secParts[1].padRight(3, '0').substring(0, 3);
      milliseconds = int.tryParse(msStr) ?? 0;
    }

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  /// Returns the subtitle text at [position], or null if no subtitle is active.
  static String? textAt(List<SubtitleItem> items, Duration position) {
    for (final item in items) {
      if (position >= item.start && position <= item.end) {
        return item.text;
      }
    }
    return null;
  }
}