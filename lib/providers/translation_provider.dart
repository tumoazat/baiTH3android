import 'package:flutter/foundation.dart';
import '../services/translation_service.dart';

class TranslationProvider extends ChangeNotifier {
  bool _isEnglish = false;
  final Map<String, String> _translations = {};
  bool _isLoading = false;

  bool get isEnglish => _isEnglish;
  bool get isLoading => _isLoading;
  
  Map<String, String> get translations => _translations;

  /// Chuyển đổi ngôn ngữ giữa Tiếng Việt và Tiếng Anh
  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }

  /// Dịch một text sang Tiếng Anh
  Future<String> translate(String text) async {
    if (text.isEmpty) return '';

    // Nếu đã dịch rồi, trả về từ cache
    if (_translations.containsKey(text)) {
      return _translations[text]!;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final translated = await TranslationService.translateToEnglish(text);
      _translations[text] = translated;
    } catch (e) {
      _translations[text] = text; // Fallback to original
    }

    _isLoading = false;
    notifyListeners();

    return _translations[text]!;
  }

  /// Dịch nhiều text cùng lúc
  Future<void> translateMultiple(List<String> texts) async {
    _isLoading = true;
    notifyListeners();

    for (final text in texts) {
      if (!_translations.containsKey(text) && text.isNotEmpty) {
        final translated = await TranslationService.translateToEnglish(text);
        _translations[text] = translated;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Lấy text dịch hoặc gốc tùy theo ngôn ngữ
  String getDisplayText(String text) {
    if (!_isEnglish) return text;
    return _translations[text] ?? text;
  }

  /// Xóa cache
  void clearCache() {
    _translations.clear();
    TranslationService.clearCache();
    notifyListeners();
  }
}
