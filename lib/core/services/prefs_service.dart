import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class PrefsService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── First launch ─────────────────────────────────────
  static bool get isFirstLaunch =>
      _prefs.getBool(AppConstants.keyFirstLaunch) ?? true;

  static Future<void> setLaunched() =>
      _prefs.setBool(AppConstants.keyFirstLaunch, false);

  // ── Similarity threshold ─────────────────────────────
  static double get savedThreshold =>
      _prefs.getDouble(AppConstants.keyDefaultThreshold) ??
      AppConstants.defaultSimilarityThreshold;

  static Future<void> saveThreshold(double v) =>
      _prefs.setDouble(AppConstants.keyDefaultThreshold, v);

  // ── Enabled extensions ───────────────────────────────
  static List<String> get enabledExtensions {
    final saved = _prefs.getStringList(AppConstants.keyScanExtensions);
    return saved ?? AppConstants.supportedExtensions;
  }

  static Future<void> saveExtensions(List<String> exts) =>
      _prefs.setStringList(AppConstants.keyScanExtensions, exts);

  // ── Last scan ────────────────────────────────────────
  static DateTime? get lastScanDate {
    final s = _prefs.getString(AppConstants.keyLastScanDate);
    return s != null ? DateTime.tryParse(s) : null;
  }

  static Future<void> saveLastScanDate() => _prefs.setString(
      AppConstants.keyLastScanDate, DateTime.now().toIso8601String());
}

