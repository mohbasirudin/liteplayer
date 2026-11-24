import 'package:equatable/equatable.dart';

import '../core/models/video_file.dart';

/// Holds the playlist files and the currently selected index.
class PlaylistState extends Equatable {
  final List<VideoFile> files;
  final int selectedIndex;

  const PlaylistState({this.files = const [], this.selectedIndex = -1});

  PlaylistState copyWith({
    List<VideoFile>? files,
    int? selectedIndex,
  }) {
    return PlaylistState(
      files: files ?? this.files,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [files, selectedIndex];
}
