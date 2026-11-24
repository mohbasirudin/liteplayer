/// Supported video file extensions.
const Set<String> kVideoExtensions = {
  'mp4',
  'mkv',
  'avi',
  'mov',
  'wmv',
  'flv',
  'webm',
  'm4v',
  'mpeg',
  'mpg',
  '3gp',
  'ts',
  'm2ts',
};

/// Supported subtitle file extensions.
const Set<String> kSubtitleExtensions = {
  'srt',
  'ass',
  'ssa',
  'sub',
  'vtt',
};

/// Returns true if [path] has a video file extension.
bool isVideoFile(String path) {
  final ext = _extensionOf(path);
  return kVideoExtensions.contains(ext);
}

/// Returns true if [path] has a subtitle file extension.
bool isSubtitleFile(String path) {
  final ext = _extensionOf(path);
  return kSubtitleExtensions.contains(ext);
}

String _extensionOf(String path) {
  final dotIndex = path.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == path.length - 1) return '';
  return path.substring(dotIndex + 1).toLowerCase();
}

/// Returns the base name without directory or extension.
///
/// Example: `/movies/The Matrix (1999).mkv` → `The Matrix (1999)`
String baseNameWithoutExtension(String path) {
  final sep = path.lastIndexOf(RegExp(r'[/\\]'));
  final filePart = sep >= 0 ? path.substring(sep + 1) : path;
  final dotIndex = filePart.lastIndexOf('.');
  if (dotIndex <= 0) return filePart;
  return filePart.substring(0, dotIndex);
}

/// Checks whether [subtitlePath] matches the video at [videoPath]
/// by comparing their base names (case-insensitive).
///
/// Example: `movie.mkv` matches `movie.srt`, `movie.en.srt`, `movie.id.srt`
bool subtitlesMatchVideo(String videoPath, String subtitlePath) {
  final videoBase = baseNameWithoutExtension(videoPath).toLowerCase();
  final subtitleBase = baseNameWithoutExtension(subtitlePath).toLowerCase();
  // Exact match: "movie.srt" matches "movie.mkv"
  if (videoBase == subtitleBase) return true;
  // Prefixed match: "movie.en.srt" matches "movie.mkv"
  if (subtitleBase.startsWith('$videoBase.')) return true;
  return false;
}