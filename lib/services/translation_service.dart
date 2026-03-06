import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // LibreTranslate API - Không giới hạn độ dài text, miễn phí
  static const String _apiUrl = 'https://libretranslate.de/api/translate';
  
  // Cache để lưu translation đã dịch
  static final Map<String, String> _cacheViToEn = {};
  static final Map<String, String> _cacheEnToVi = {};

  /// Dịch text từ Tiếng Việt sang Tiếng Anh
  /// Sử dụng LibreTranslate API - miễn phí, không giới hạn độ dài
  static Future<String> translateToEnglish(String text) async {
    if (text.isEmpty) return '';

    // Check cache trước
    if (_cacheViToEn.containsKey(text)) {
      return _cacheViToEn[text]!;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'q': text,
              'source': 'vi',
              'target': 'en',
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final translatedText =
            json['translatedText'] as String? ?? text;

        // Lưu vào cache
        _cacheViToEn[text] = translatedText;
        return translatedText;
      }
    } catch (e) {
      print('Translation error: $e');
    }

    return text; // Return original text nếu lỗi
  }

  /// Dịch text từ Tiếng Anh sang Tiếng Việt
  static Future<String> translateToVietnamese(String text) async {
    if (text.isEmpty) return '';

    // Check cache trước
    if (_cacheEnToVi.containsKey(text)) {
      return _cacheEnToVi[text]!;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'q': text,
              'source': 'en',
              'target': 'vi',
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final translatedText =
            json['translatedText'] as String? ?? text;

        // Lưu vào cache
        _cacheEnToVi[text] = translatedText;
        return translatedText;
      }
    } catch (e) {
      print('Translation error: $e');
    }

    return text; // Return original text nếu lỗi
  }

  /// Dịch nhiều text cùng lúc (Việt -> Anh)
  static Future<List<String>> translateMultiple(List<String> texts) async {
    final results = <String>[];
    for (final text in texts) {
      final translated = await translateToEnglish(text);
      results.add(translated);
    }
    return results;
  }

  /// Dịch nhiều text cùng lúc (Anh -> Việt)
  static Future<List<String>> translateMultipleToVietnamese(
      List<String> texts) async {
    final results = <String>[];
    for (final text in texts) {
      final translated = await translateToVietnamese(text);
      results.add(translated);
    }
    return results;
  }

  /// Xóa cache
  static void clearCache() {
    _cacheViToEn.clear();
    _cacheEnToVi.clear();
  }

  /// Lấy số lượng item trong cache
  static int getCacheSize() =>
      _cacheViToEn.length + _cacheEnToVi.length;
}
