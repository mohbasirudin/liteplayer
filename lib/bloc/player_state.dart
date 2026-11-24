import 'package:equatable/equatable.dart';

import '../core/models/video_file.dart';

/// States that [PlayerBloc] can emit.
sealed class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

/// No video loaded yet.
class PlayerInitial extends PlayerState {
  const PlayerInitial();
}

/// A video is loaded and ready to play.
class PlayerLoaded extends PlayerState {
  final String videoPath;
  final String? subtitlePath;
  final List<SubtitleItem> subtitles;
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  const PlayerLoaded({
    required this.videoPath,
    this.subtitlePath,
    required this.subtitles,
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  PlayerLoaded copyWith({
    String? videoPath,
    String? subtitlePath,
    List<SubtitleItem>? subtitles,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
  }) {
    return PlayerLoaded(
      videoPath: videoPath ?? this.videoPath,
      subtitlePath: subtitlePath ?? this.subtitlePath,
      subtitles: subtitles ?? this.subtitles,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [
    videoPath,
    subtitlePath,
    subtitles,
    position,
    duration,
    isPlaying,
  ];
}

/// Playback encountered an error.
class PlayerError extends PlayerState {
  final String message;

  const PlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
