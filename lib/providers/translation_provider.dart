import 'package:flutter/foundation.dart';
import '../services/translation_service.dart';

class TranslationProvider extends ChangeNotifier {
  bool _isEnglish = false;
  final Map<String, String> _translationsViToEn = {};
  final Map<String, String> _translationsEnToVi = {};
  bool _isLoading = false;

  bool get isEnglish => _isEnglish;
  bool get isLoading => _isLoading;
  
  Map<String, String> get translations => _isEnglish ? _translationsViToEn : _translationsEnToVi;

  /// Chuyển đổi ngôn ngữ giữa Tiếng Việt và Tiếng Anh
  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }

  /// Dịch text từ Tiếng Việt sang Tiếng Anh
  Future<String> translateToEnglish(String text) async {
    if (text.isEmpty) return '';

    // Nếu đã dịch rồi, trả về từ cache
    if (_translationsViToEn.containsKey(text)) {
      return _translationsViToEn[text]!;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final translated = await TranslationService.translateToEnglish(text);
      _translationsViToEn[text] = translated;
    } catch (e) {
      _translationsViToEn[text] = text; // Fallback to original
    }

    _isLoading = false;
    notifyListeners();

    return _translationsViToEn[text]!;
  }

  /// Dịch text từ Tiếng Anh sang Tiếng Việt
  Future<String> translateToVietnamese(String text) async {
    if (text.isEmpty) return '';

    // Nếu đã dịch rồi, trả về từ cache
    if (_translationsEnToVi.containsKey(text)) {
      return _translationsEnToVi[text]!;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final translated = await TranslationService.translateToVietnamese(text);
      _translationsEnToVi[text] = translated;
    } catch (e) {
      _translationsEnToVi[text] = text; // Fallback to original
    }

    _isLoading = false;
    notifyListeners();

    return _translationsEnToVi[text]!;
  }

  /// Dịch nhiều text cùng lúc (Việt -> Anh)
  Future<void> translateMultiple(List<String> texts) async {
    _isLoading = true;
    notifyListeners();

    for (final text in texts) {
      if (!_translationsViToEn.containsKey(text) && text.isNotEmpty) {
        final translated = await TranslationService.translateToEnglish(text);
        _translationsViToEn[text] = translated;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Dịch nhiều text cùng lúc (Anh -> Việt)
  Future<void> translateMultipleToVietnamese(List<String> texts) async {
    _isLoading = true;
    notifyListeners();

    for (final text in texts) {
      if (!_translationsEnToVi.containsKey(text) && text.isNotEmpty) {
        final translated = await TranslationService.translateToVietnamese(text);
        _translationsEnToVi[text] = translated;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Lấy text dịch hoặc gốc tùy theo ngôn ngữ
  String getDisplayText(String text) {
    if (!_isEnglish) return text;
    return _translationsViToEn[text] ?? text;
  }

  /// Lấy translation cụ thể (Việt -> Anh)
  String? getEnglishTranslation(String text) => _translationsViToEn[text];

  /// Lấy translation cụ thể (Anh -> Việt)
  String? getVietnameseTranslation(String text) => _translationsEnToVi[text];

  /// Xóa cache
  void clearCache() {
    _translationsViToEn.clear();
    _translationsEnToVi.clear();
    TranslationService.clearCache();
    notifyListeners();
  }
}
