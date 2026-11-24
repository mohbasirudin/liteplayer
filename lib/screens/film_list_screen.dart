import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';
import '../bloc/playlist_state.dart';
import '../core/models/video_file.dart';
import '../core/utils/file_utils.dart';
import 'player_screen.dart';

/// Screen that lists video files in a selected folder.
class FilmListScreen extends StatefulWidget {
  const FilmListScreen({super.key});

  @override
  State<FilmListScreen> createState() => _FilmListScreenState();
}

class _FilmListScreenState extends State<FilmListScreen> {
  final PlaylistBloc _playlistBloc = PlaylistBloc();
  bool _isLoading = false;

  @override
  void dispose() {
    _playlistBloc.close();
    super.dispose();
  }

  Future<void> _pickFolder() async {
    setState(() => _isLoading = true);

    try {
      final String? directoryPath = await getDirectoryPath(
        initialDirectory: null,
        canCreateDirectories: false,
      );

      if (directoryPath == null || directoryPath.isEmpty) {
        // User cancelled
        return;
      }

      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected folder does not exist.')),
          );
        }
        return;
      }

      final paths = <String>[];
      await for (final entity in directory.list()) {
        if (entity is File && isVideoFile(entity.path)) {
          paths.add(entity.path);
        }
      }

      // Sort alphabetically
      paths.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      final files =
          paths.map((p) => VideoFile(
                path: p,
                name: p.split(RegExp(r'[/\\]')).last,
              )).toList();

      _playlistBloc.add(PlaylistLoad(files));

      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No video files found in this folder.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open folder: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LitePlayer'),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (_) => _playlistBloc,
        child: BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: (context, state) {
            final files = state.files;

            return Column(
              children: [
                // Folder picker bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Open Folder'),
                          onPressed: _isLoading ? null : _pickFolder,
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
                // File list
                Expanded(
                  child: files.isEmpty
                      ? const Center(
                          child: Text(
                            'No videos loaded.\nTap "Open Folder" to pick a folder.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          itemCount: files.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final file = files[index];
                            final isSelected = index == state.selectedIndex;
                            return ListTile(
                              leading: const Icon(Icons.video_library),
                              title: Text(file.name),
                              subtitle: Text(file.path,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.blue)
                                  : null,
                              selected: isSelected,
                              selectedTileColor:
                                  Colors.blue.withValues(alpha: 0.08),
                              onTap: () {
                                _playlistBloc.add(PlaylistSelect(index));
                                // Navigate to player screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerScreen(
                                      videoFile: file,
                                      playlist: files,
                                      currentIndex: index,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
