import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class FileScannerService {
  final Logger _log = Logger();

  static const _skipDirs = {
    'Android/data',
    'Android/obb',
    '.thumbnails',
    '.cache',
    'cache',
    '.trash',
  };

  Future<List<String>> scanDevice({
    List<String> allowedExtensions = const ['pdf', 'docx', 'doc', 'txt'],
  }) async {
    final roots = await _getRoots();
    final extSet = allowedExtensions.map((e) => e.toLowerCase()).toSet();
    final results = <String>[];

    for (final root in roots) {
      await _scanDir(Directory(root), extSet, results);
    }

    _log.i('Scan complete: ${results.length} files found');
    return results;
  }

  Future<void> _scanDir(
    Directory dir,
    Set<String> extSet,
    List<String> results,
  ) async {
    try {
      await for (final entity in dir.list(recursive: false)) {
        final path = entity.path;
        final name = path.split('/').last;

        if (name.startsWith('.')) continue;
        if (_skipDirs.any((skip) => path.contains(skip))) continue;

        if (entity is Directory) {
          await _scanDir(entity, extSet, results);
        } else if (entity is File) {
          final ext = name.contains('.')
              ? name.split('.').last.toLowerCase()
              : '';
          if (extSet.contains(ext)) {
            results.add(path);
          }
        }
      }
    } catch (_) {}
  }

  Future<List<String>> _getRoots() async {
    final roots = <String>[];

    try {
      final internal = await getExternalStorageDirectory();
      if (internal != null) {
        var path = internal.path;
        while (!path.endsWith('/0') && !path.endsWith('/sdcard')) {
          final parent = Directory(path).parent.path;
          if (parent == path) break;
          path = parent;
        }
        roots.add(path);
      }
    } catch (_) {}

    try {
      final dl = Directory('/storage/emulated/0/Download');
      if (await dl.exists()) roots.add(dl.path);
    } catch (_) {}

    try {
      final docs = Directory('/storage/emulated/0/Documents');
      if (await docs.exists()) roots.add(docs.path);
    } catch (_) {}

    return roots.toSet().toList();
  }
}
