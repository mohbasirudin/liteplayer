import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../bloc/player_bloc.dart';
import '../bloc/player_event.dart';
import '../bloc/player_state.dart' as bloc_state;
import '../core/models/video_file.dart';
import '../core/utils/file_utils.dart';

/// Screen that plays a video file with subtitles.
class PlayerScreen extends StatefulWidget {
  final VideoFile videoFile;
  final List<VideoFile> playlist;
  final int currentIndex;

  const PlayerScreen({
    super.key,
    required this.videoFile,
    required this.playlist,
    required this.currentIndex,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerBloc _playerBloc;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _playerBloc = PlayerBloc();
    _controller = VideoController(_playerBloc.player);

    _loadVideoWithSubtitle(widget.videoFile);
  }

  Future<void> _loadVideoWithSubtitle(VideoFile file) async {
    String? subtitlePath;
    try {
      final path = file.path;
      final lastSep = path.lastIndexOf(RegExp(r'[/\\]'));
      final dir = lastSep >= 0 ? path.substring(0, lastSep) : '';
      final base = baseNameWithoutExtension(path);

      final candidates = [
        '$dir/$base.srt',
        '$dir/$base.vtt',
        '$dir/$base.ass',
      ];

      for (final candidate in candidates) {
        if (await File(candidate).exists()) {
          subtitlePath = candidate;
          break;
        }
      }
    } catch (_) {
      subtitlePath = null;
    }

    _playerBloc.add(PlayerLoadVideo(
      videoPath: file.path,
      subtitlePath: subtitlePath,
    ));
  }

  @override
  void dispose() {
    _playerBloc.close();
    super.dispose();
  }

  void _next() {
    if (widget.currentIndex + 1 < widget.playlist.length) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerScreen(
            videoFile: widget.playlist[widget.currentIndex + 1],
            playlist: widget.playlist,
            currentIndex: widget.currentIndex + 1,
          ),
        ),
      );
    }
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Top bar with playlist info and close
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.videoFile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.currentIndex + 1} of ${widget.playlist.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: () {
                  // Simple fullscreen toggle
                },
              ),
            ],
          ),
        ),
        const Spacer(),
        Positioned(
          bottom: 140,
          left: 0,
          right: 0,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                shadows: [
                  Shadow(
                    blurRadius: 6,
                    color: Colors.black,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _playerBloc,
      child: BlocListener<PlayerBloc, bloc_state.PlayerState>(
        listener: (context, state) {
          if (state is bloc_state.PlayerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<PlayerBloc, bloc_state.PlayerState>(
          builder: (context, state) {
            final isLoaded = state is bloc_state.PlayerLoaded;
            final position = isLoaded ? state.position : Duration.zero;
            final subtitleText = isLoaded
                ? _subtitleTextAt(state.subtitles, position)
                : null;

            return Scaffold(
              body: Stack(
                children: [
                  Expanded(
                    child: Center(
                      child: Video(controller: _controller),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

String? _subtitleTextAt(List<SubtitleItem> subtitles, Duration position) {
  for (final sub in subtitles) {
    if (position >= sub.start && position <= sub.end) {
      return sub.text;
    }
  }
  return null;
}
