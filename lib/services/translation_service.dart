import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // LibreTranslate API - Không giới hạn độ dài text, miễn phí
  static const String _libreTranslateUrl = 'https://libretranslate.de/api/translate';
  
  // Google Translate Unofficial API (Fallback)
  static const String _googleTranslateUrl = 'https://translate.googleapis.com/translate_a/element.js?cb=googleTranslateElementInit';
  
  // Reverso API (Fallback 2)
  static const String _reversoUrl = 'https://api.reverso.net/translate/text';
  
  // Cache để lưu translation đã dịch
  static final Map<String, String> _cacheViToEn = {};
  static final Map<String, String> _cacheEnToVi = {};

  /// Dịch text từ Tiếng Việt sang Tiếng Anh
  /// Thử LibreTranslate trước, fallback sang Reverso nếu lỗi
  static Future<String> translateToEnglish(String text) async {
    if (text.isEmpty) return '';

    // Check cache trước
    if (_cacheViToEn.containsKey(text)) {
      return _cacheViToEn[text]!;
    }

    // Thử LibreTranslate trước
    try {
      final result = await _libreTranslateToEnglish(text);
      if (result.isNotEmpty) {
        _cacheViToEn[text] = result;
        return result;
      }
    } catch (e) {
      print('LibreTranslate error: $e, trying Reverso...');
    }

    // Fallback: Reverso API
    try {
      final result = await _reversoToEnglish(text);
      if (result.isNotEmpty) {
        _cacheViToEn[text] = result;
        return result;
      }
    } catch (e) {
      print('Reverso error: $e');
    }

    return text; // Return original text nếu tất cả lỗi
  }

  /// LibreTranslate: Việt -> Anh
  static Future<String> _libreTranslateToEnglish(String text) async {
    final response = await http
        .post(
          Uri.parse(_libreTranslateUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'q': text,
            'source': 'vi',
            'target': 'en',
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['translatedText'] as String? ?? '';
    }
    return '';
  }

  /// Reverso API: Việt -> Anh
  static Future<String> _reversoToEnglish(String text) async {
    final response = await http
        .post(
          Uri.parse(_reversoUrl),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'text': text,
            'from': 'vie',
            'to': 'eng',
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['result'] != null && json['result']['translatedText'] != null) {
        return json['result']['translatedText'] as String;
      }
    }
    return '';
  }

  /// Dịch text từ Tiếng Anh sang Tiếng Việt
  /// Thử LibreTranslate trước, fallback sang Reverso nếu lỗi
  static Future<String> translateToVietnamese(String text) async {
    if (text.isEmpty) return '';

    // Check cache trước
    if (_cacheEnToVi.containsKey(text)) {
      return _cacheEnToVi[text]!;
    }

    // Thử LibreTranslate trước
    try {
      final result = await _libreTranslateToVietnamese(text);
      if (result.isNotEmpty) {
        _cacheEnToVi[text] = result;
        return result;
      }
    } catch (e) {
      print('LibreTranslate error: $e, trying Reverso...');
    }

    // Fallback: Reverso API
    try {
      final result = await _reversoToVietnamese(text);
      if (result.isNotEmpty) {
        _cacheEnToVi[text] = result;
        return result;
      }
    } catch (e) {
      print('Reverso error: $e');
    }

    return text; // Return original text nếu tất cả lỗi
  }

  /// LibreTranslate: Anh -> Việt
  static Future<String> _libreTranslateToVietnamese(String text) async {
    final response = await http
        .post(
          Uri.parse(_libreTranslateUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'q': text,
            'source': 'en',
            'target': 'vi',
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['translatedText'] as String? ?? '';
    }
    return '';
  }

  /// Reverso API: Anh -> Việt
  static Future<String> _reversoToVietnamese(String text) async {
    final response = await http
        .post(
          Uri.parse(_reversoUrl),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'text': text,
            'from': 'eng',
            'to': 'vie',
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['result'] != null && json['result']['translatedText'] != null) {
        return json['result']['translatedText'] as String;
      }
    }
    return '';
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
