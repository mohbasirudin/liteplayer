import 'package:flutter_bloc/flutter_bloc.dart';

import 'playlist_event.dart';
import 'playlist_state.dart';

/// BLoC that manages a list of video files and the current selection.
class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  PlaylistBloc() : super(const PlaylistState()) {
    on<PlaylistLoad>(_onLoad);
    on<PlaylistSelect>(_onSelect);
    on<PlaylistNext>(_onNext);
    on<PlaylistPrevious>(_onPrevious);
    on<PlaylistAddFiles>(_onAddFiles);
    on<PlaylistClear>(_onClear);
  }

  void _onLoad(PlaylistLoad event, Emitter<PlaylistState> emit) {
    emit(PlaylistState(files: List.unmodifiable(event.files)));
  }

  void _onSelect(PlaylistSelect event, Emitter<PlaylistState> emit) {
    final current = state;
    if (event.index >= 0 && event.index < current.files.length) {
      emit(current.copyWith(selectedIndex: event.index));
    }
  }

  void _onNext(PlaylistNext event, Emitter<PlaylistState> emit) {
    final current = state;
    if (current.files.isEmpty) return;

    final nextIndex = current.selectedIndex + 1;
    if (nextIndex < current.files.length) {
      emit(current.copyWith(selectedIndex: nextIndex));
    } else {
      // Loop back to first
      emit(current.copyWith(selectedIndex: 0));
    }
  }

  void _onPrevious(PlaylistPrevious event, Emitter<PlaylistState> emit) {
    final current = state;
    if (current.files.isEmpty) return;

    final prevIndex = current.selectedIndex - 1;
    if (prevIndex >= 0) {
      emit(current.copyWith(selectedIndex: prevIndex));
    } else {
      // Wrap to last
      emit(current.copyWith(selectedIndex: current.files.length - 1));
    }
  }

  void _onAddFiles(PlaylistAddFiles event, Emitter<PlaylistState> emit) {
    final current = state;
    final combined = [...current.files, ...event.files];
    emit(PlaylistState(
      files: List.unmodifiable(combined),
      selectedIndex: current.selectedIndex,
    ));
  }

  void _onClear(PlaylistClear event, Emitter<PlaylistState> emit) {
    emit(const PlaylistState());
  }
}