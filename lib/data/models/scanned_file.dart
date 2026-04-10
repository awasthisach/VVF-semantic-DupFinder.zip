import 'package:equatable/equatable.dart';

enum FileSource { localStorage, googleDrive, selected }

class ScannedFile extends Equatable {
  final String id;
  final String name;
  final String path;
  final String extension;
  final int sizeBytes;
  final DateTime modifiedAt;
  final DateTime scannedAt;
  final String? textContent;
  final FileSource source;

  const ScannedFile({
    required this.id,
    required this.name,
    required this.path,
    required this.extension,
    required this.sizeBytes,
    required this.modifiedAt,
    required this.scannedAt,
    this.textContent,
    required this.source,
  });

  bool get hasText => textContent != null && textContent!.isNotEmpty;

  String get sizeFormatted {
    if (sizeBytes > 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (sizeBytes > 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$sizeBytes B';
  }

  @override
  List<Object?> get props => [id, path, scannedAt];
}

