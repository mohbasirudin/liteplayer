import 'package:equatable/equatable.dart';

/// Events that can be dispatched to [PlayerBloc].
sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Load a new video file, optionally with a subtitle file.
class PlayerLoadVideo extends PlayerEvent {
  final String videoPath;
  final String? subtitlePath;

  const PlayerLoadVideo({
    required this.videoPath,
    this.subtitlePath,
  });

  @override
  List<Object?> get props => [videoPath, subtitlePath];
}

/// Play or resume playback.
class PlayerPlay extends PlayerEvent {
  const PlayerPlay();
}

/// Pause playback.
class PlayerPause extends PlayerEvent {
  const PlayerPause();
}

/// Seek forward by 5 seconds.
class PlayerForward5s extends PlayerEvent {
  const PlayerForward5s();
}

/// Seek backward by 5 seconds.
class PlayerBackward5s extends PlayerEvent {
  const PlayerBackward5s();
}

/// Load a different subtitle file.
class PlayerLoadSubtitle extends PlayerEvent {
  final String? subtitlePath;

  const PlayerLoadSubtitle({this.subtitlePath});

  @override
  List<Object?> get props => [subtitlePath];
}

/// Reset the player state.
class PlayerReset extends PlayerEvent {
  const PlayerReset();
}

/// Event for position updates (dispatched by UI from the player stream).
class PlayerPositionUpdated extends PlayerEvent {
  final Duration position;
  final Duration duration;

  const PlayerPositionUpdated(this.position, this.duration);

  @override
  List<Object?> get props => [position, duration];
}

/// Event for playback state changes (dispatched by UI from the player stream).
class PlayerPlaybackStateChanged extends PlayerEvent {
  final bool isPlaying;

  const PlayerPlaybackStateChanged(this.isPlaying);

  @override
  List<Object?> get props => [isPlaying];
}

/// Event for player errors (dispatched by UI from the player stream).
class PlayerErrorOccurred extends PlayerEvent {
  final String message;

  const PlayerErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
