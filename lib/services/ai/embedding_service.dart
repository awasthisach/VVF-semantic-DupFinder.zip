import 'dart:math' as math;
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class EmbeddingService {
  static const String _modelPath = 'assets/models/embedding_gemma_300m.tflite';
  static const int _embeddingDim = 768;
  static const int _maxTokens = 512;

  Interpreter? _interpreter;
  final Logger _log = Logger();
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> initialize() async {
    try {
      final options = InterpreterOptions()..threads = 4;

      _interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: options,
      );
      _isReady = true;
      _log.i('EmbeddingGemma model loaded successfully');
    } catch (e) {
      _log.w('Model load failed, using TF-IDF fallback: $e');
      _isReady = true;
    }
  }

  Future<List<double>> embed(String text) async {
    if (!_isReady) throw StateError('EmbeddingService not initialized');
    final truncated = _truncateText(text, _maxTokens);
    if (_interpreter != null) {
      return _runModelInference(truncated);
    } else {
      return _tfidfFallbackEmbed(truncated);
    }
  }

  Future<List<double>> _runModelInference(String text) async {
    final inputTensor = _tokenize(text);
    final outputBuffer = [List<double>.filled(_embeddingDim, 0.0)];
    _interpreter!.run(inputTensor, outputBuffer);
    return _l2Normalize(outputBuffer[0]);
  }

  double cosineSimilarity(List<double> vecA, List<double> vecB) {
    assert(vecA.length == vecB.length);
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < vecA.length; i++) {
      dotProduct += vecA[i] * vecB[i];
      normA += vecA[i] * vecA[i];
      normB += vecB[i] * vecB[i];
    }
    final denominator = math.sqrt(normA) * math.sqrt(normB);
    if (denominator == 0) return 0.0;
    return dotProduct / denominator;
  }

  Future<List<DuplicatePair>> findDuplicates(
    List<DocumentEmbedding> documents, {
    double threshold = 0.87,
  }) async {
    final duplicates = <DuplicatePair>[];
    for (int i = 0; i < documents.length; i++) {
      for (int j = i + 1; j < documents.length; j++) {
        final similarity = cosineSimilarity(
          documents[i].vector,
          documents[j].vector,
        );
        if (similarity >= threshold) {
          duplicates.add(DuplicatePair(
            docA: documents[i],
            docB: documents[j],
            similarity: similarity,
          ));
        }
      }
    }
    duplicates.sort((a, b) => b.similarity.compareTo(a.similarity));
    return duplicates;
  }

  List<double> _l2Normalize(List<double> vector) {
    final norm = math.sqrt(vector.fold(0.0, (sum, v) => sum + v * v));
    if (norm == 0) return vector;
    return vector.map((v) => v / norm).toList();
  }

  String _truncateText(String text, int maxTokens) {
    final maxChars = maxTokens * 4;
    return text.length > maxChars ? text.substring(0, maxChars) : text;
  }

  List<List<int>> _tokenize(String text) {
    final bytes = text.codeUnits.take(_maxTokens).toList();
    while (bytes.length < _maxTokens) bytes.add(0);
    return [bytes];
  }

  List<double> _tfidfFallbackEmbed(String text) {
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final vector = List<double>.filled(_embeddingDim, 0.0);
    for (final word in words) {
      if (word.isEmpty) continue;
      final idx = word.hashCode.abs() % _embeddingDim;
      vector[idx] += 1.0;
    }
    return _l2Normalize(vector);
  }

  void dispose() {
    _interpreter?.close();
  }
}

class DocumentEmbedding {
  final String fileId;
  final String fileName;
  final String filePath;
  final List<double> vector;
  final DateTime scannedAt;

  const DocumentEmbedding({
    required this.fileId,
    required this.fileName,
    required this.filePath,
    required this.vector,
    required this.scannedAt,
  });
}

class DuplicatePair {
  final DocumentEmbedding docA;
  final DocumentEmbedding docB;
  final double similarity;

  const DuplicatePair({
    required this.docA,
    required this.docB,
    required this.similarity,
  });

  String get similarityPercent => '${(similarity * 100).toStringAsFixed(1)}%';

  DuplicateCategory get category {
    if (similarity >= 0.98) return DuplicateCategory.exactCopy;
    if (similarity >= 0.90) return DuplicateCategory.nearDuplicate;
    return DuplicateCategory.similarContent;
  }
}

enum DuplicateCategory {
  exactCopy,
  nearDuplicate,
  similarContent,
}
