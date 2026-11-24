import 'package:equatable/equatable.dart';

import '../core/models/video_file.dart';

/// Events that can be dispatched to [PlaylistBloc].
sealed class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

/// Load a fresh list of video files into the playlist.
class PlaylistLoad extends PlaylistEvent {
  final List<VideoFile> files;

  const PlaylistLoad(this.files);

  @override
  List<Object?> get props => [files];
}

/// Select a video file at [index] as the current item.
class PlaylistSelect extends PlaylistEvent {
  final int index;

  const PlaylistSelect(this.index);

  @override
  List<Object?> get props => [index];
}

/// Move to the next item in the playlist.
class PlaylistNext extends PlaylistEvent {
  const PlaylistNext();
}

/// Move to the previous item in the playlist.
class PlaylistPrevious extends PlaylistEvent {
  const PlaylistPrevious();
}

/// Append files to the existing playlist.
class PlaylistAddFiles extends PlaylistEvent {
  final List<VideoFile> files;

  const PlaylistAddFiles(this.files);

  @override
  List<Object?> get props => [files];
}

/// Clear the playlist.
class PlaylistClear extends PlaylistEvent {
  const PlaylistClear();
}
