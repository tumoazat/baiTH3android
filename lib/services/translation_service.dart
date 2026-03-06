import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String _apiUrl = 'https://api.mymemory.translated.net/get';
  
  // Cache để lưu translation đã dịch
  static final Map<String, String> _cacheViToEn = {};
  static final Map<String, String> _cacheEnToVi = {};

  /// Dịch text từ Tiếng Việt sang Tiếng Anh
  /// Sử dụng MyMemory API - miễn phí, không cần API key
  static Future<String> translateToEnglish(String text) async {
    if (text.isEmpty) return '';

    // Check cache trước
    if (_cacheViToEn.containsKey(text)) {
      return _cacheViToEn[text]!;
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_apiUrl?q=${Uri.encodeComponent(text)}&langpair=vi|en'),
          )
          .timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final translatedText =
            json['responseData']['translatedText'] as String? ?? text;

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
          .get(
            Uri.parse('$_apiUrl?q=${Uri.encodeComponent(text)}&langpair=en|vi'),
          )
          .timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final translatedText =
            json['responseData']['translatedText'] as String? ?? text;

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
