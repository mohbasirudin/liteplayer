import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;

import '../core/models/video_file.dart';
import '../core/utils/subtitle_parser.dart';

import 'player_event.dart';
import 'player_state.dart';

/// BLoC that manages video playback state.
///
/// Owns the underlying [media_kit.Player] and controls playback.
/// Position and playback-state updates flow back from the player streams
/// into emitted states.
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  late final Player _player;
  List<SubtitleItem> _subtitles = [];

  /// Exposes the underlying player so the UI can bind it to a [VideoController].
  Player get player => _player;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _playingSubscription;

  PlayerBloc() : super(const PlayerInitial()) {
    _player = Player();

    _positionSubscription = _player.stream.position.listen((position) {
      add(PlayerPositionUpdated(position, _player.state.duration));
    });

    _playingSubscription = _player.stream.playing.listen((playing) {
      add(PlayerPlaybackStateChanged(playing));
    });

    on<PlayerLoadVideo>(_onLoadVideo);
    on<PlayerPlay>(_onPlay);
    on<PlayerPause>(_onPause);
    on<PlayerForward5s>(_onForward5s);
    on<PlayerBackward5s>(_onBackward5s);
    on<PlayerLoadSubtitle>(_onLoadSubtitle);
    on<PlayerReset>(_onReset);
    on<PlayerPositionUpdated>(_onPositionUpdated);
    on<PlayerPlaybackStateChanged>(_onPlaybackStateChanged);
    on<PlayerErrorOccurred>(_onError);
  }

  Future<void> _onLoadVideo(
    PlayerLoadVideo event,
    Emitter<PlayerState> emit,
  ) async {
    _subtitles = [];

    // Load subtitle text (parsed) for UI overlay
    if (event.subtitlePath != null) {
      try {
        _subtitles = await SubtitleParser.parseFile(event.subtitlePath!);
      } catch (_) {
        _subtitles = [];
      }
    }

    // Open the media in the underlying player
    try {
      await _player.open(Media(event.videoPath));

      // Load external subtitle track if found
      if (event.subtitlePath != null) {
        try {
          await _player.setSubtitleTrack(
            SubtitleTrack.uri(
              event.subtitlePath!,
              title: 'Subtitle',
              language: 'und',
            ),
          );
        } catch (_) {
          // Subtitle track load failure is non-fatal
        }
      }
    } catch (e) {
      emit(PlayerError('Failed to open video: $e'));
      return;
    }

    emit(PlayerLoaded(
      videoPath: event.videoPath,
      subtitlePath: event.subtitlePath,
      subtitles: _subtitles,
      position: Duration.zero,
      duration: _player.state.duration,
      isPlaying: false,
    ));
  }

  void _onPlay(PlayerPlay event, Emitter<PlayerState> emit) {
    _player.play();
    final current = state;
    if (current is PlayerLoaded) {
      emit(current.copyWith(isPlaying: true));
    }
  }

  void _onPause(PlayerPause event, Emitter<PlayerState> emit) {
    _player.pause();
    final current = state;
    if (current is PlayerLoaded) {
      emit(current.copyWith(isPlaying: false));
    }
  }

  void _onForward5s(PlayerForward5s event, Emitter<PlayerState> emit) {
    final current = state;
    if (current is PlayerLoaded) {
      final newPos = current.position + const Duration(seconds: 5);
      _player.seek(newPos);
    }
  }

  void _onBackward5s(PlayerBackward5s event, Emitter<PlayerState> emit) {
    final current = state;
    if (current is PlayerLoaded) {
      final newPos = current.position - const Duration(seconds: 5);
      if (newPos > Duration.zero) {
        _player.seek(newPos);
      }
    }
  }

  Future<void> _onLoadSubtitle(
    PlayerLoadSubtitle event,
    Emitter<PlayerState> emit,
  ) async {
    final current = state;
    if (current is! PlayerLoaded) return;

    _subtitles = [];

    if (event.subtitlePath != null) {
      try {
        _subtitles = await SubtitleParser.parseFile(event.subtitlePath!);
      } catch (e) {
        emit(PlayerError('Failed to load subtitle: $e'));
        return;
      }
    }

    emit(current.copyWith(
      subtitlePath: event.subtitlePath,
      subtitles: _subtitles,
    ));
  }

  Future<void> _onReset(
    PlayerReset event,
    Emitter<PlayerState> emit,
  ) async {
    await _player.dispose();
    _subtitles = [];
    emit(const PlayerInitial());
  }

  void _onPositionUpdated(
    PlayerPositionUpdated event,
    Emitter<PlayerState> emit,
  ) {
    final current = state;
    if (current is PlayerLoaded) {
      emit(current.copyWith(
        position: event.position,
        duration: event.duration,
      ));
    }
  }

  void _onPlaybackStateChanged(
    PlayerPlaybackStateChanged event,
    Emitter<PlayerState> emit,
  ) {
    final current = state;
    if (current is PlayerLoaded) {
      emit(current.copyWith(isPlaying: event.isPlaying));
    }
  }

  void _onError(PlayerErrorOccurred event, Emitter<PlayerState> emit) {
    emit(PlayerError(event.message));
  }

  @override
  Future<void> close() async {
    _positionSubscription?.cancel();
    _playingSubscription?.cancel();
    await _player.dispose();
    _subtitles = [];
    return super.close();
  }
}
