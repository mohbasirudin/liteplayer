import 'package:equatable/equatable.dart';

/// A video file discovered in a folder.
class VideoFile extends Equatable {
  final String path;
  final String name;
  final Duration? duration;

  const VideoFile({
    required this.path,
    required this.name,
    this.duration,
  });

  @override
  List<Object?> get props => [path, name, duration];
}

/// A single subtitle entry parsed from an .srt file.
class SubtitleItem extends Equatable {
  final int index;
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleItem({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
  });

  @override
  List<Object?> get props => [index, start, end, text];
}