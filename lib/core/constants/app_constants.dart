class AppConstants {
  AppConstants._();

  // AI thresholds
  static const double defaultSimilarityThreshold = 0.87;
  static const double minThreshold = 0.80;
  static const double maxThreshold = 0.99;

  // Scan limits
  static const int maxDriveFiles = 200;
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  // Supported file types
  static const List<String> supportedExtensions = [
    'pdf', 'docx', 'doc', 'txt', 'md', 'jpg', 'jpeg', 'png',
  ];

  // Embedding
  static const int embeddingDimensions = 768;
  static const int maxTextTokens = 512;

  // SharedPreferences keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDefaultThreshold = 'default_threshold';
  static const String keyLastScanDate = 'last_scan_date';
  static const String keyScanExtensions = 'scan_extensions';
}

