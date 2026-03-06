import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // Google Translate Unofficial API
  static const String _googleUrl = 'https://translate.googleapis.com/translate_a/single';
  
  // LibreTranslate API - Fallback
  static const String _libreTranslateUrl = 'https://libretranslate.de/api/translate';
  
  // Cache để lưu translation đã dịch
  static final Map<String, String> _cacheViToEn = {};
  static final Map<String, String> _cacheEnToVi = {};

  /// Dịch text từ Tiếng Việt sang Tiếng Anh
  /// Thử Google Translate trước, fallback LibreTranslate
  static Future<String> translateToEnglish(String text) async {
    if (text.isEmpty) return '';

    // Check cache trước
    if (_cacheViToEn.containsKey(text)) {
      return _cacheViToEn[text]!;
    }

    // Thử Google Translate trước
    try {
      final result = await _googleTranslateToEnglish(text);
      if (result.isNotEmpty) {
        _cacheViToEn[text] = result;
        return result;
      }
    } catch (e) {
      print('Google Translate error: $e, trying LibreTranslate...');
    }

    // Fallback: LibreTranslate API
    try {
      final result = await _libreTranslateToEnglish(text);
      if (result.isNotEmpty) {
        _cacheViToEn[text] = result;
        return result;
      }
    } catch (e) {
      print('LibreTranslate error: $e');
    }

    return text; // Return original text nếu tất cả lỗi
  }

  /// Google Translate: Việt -> Anh
  static Future<String> _googleTranslateToEnglish(String text) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_googleUrl?client=gtx&sl=vi&tl=en&dt=t&q=${Uri.encodeComponent(text)}',
            ),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        // Parse Google's response format: [[[translated_text,original_text,...],...],...]
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is List && decoded.isNotEmpty) {
            final translations = decoded[0];
            if (translations is List && translations.isNotEmpty) {
              final firstTranslation = translations[0];
              if (firstTranslation is List && firstTranslation.isNotEmpty) {
                return firstTranslation[0] as String;
              }
            }
          }
        } catch (e) {
          print('Parse error: $e');
        }
      }
    } catch (e) {
      print('Google Translate request error: $e');
    }
    return '';
  }

  /// LibreTranslate: Việt -> Anh (Fallback)
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

  /// Dịch text từ Tiếng Anh sang Tiếng Việt
  /// Thử Google Translate trước, fallback LibreTranslate
  static Future<String> translateToVietnamese(String text) async {
    if (text.isEmpty) return '';

    // Check cache trước
    if (_cacheEnToVi.containsKey(text)) {
      return _cacheEnToVi[text]!;
    }

    // Thử Google Translate trước
    try {
      final result = await _googleTranslateToVietnamese(text);
      if (result.isNotEmpty) {
        _cacheEnToVi[text] = result;
        return result;
      }
    } catch (e) {
      print('Google Translate error: $e, trying LibreTranslate...');
    }

    // Fallback: LibreTranslate API
    try {
      final result = await _libreTranslateToVietnamese(text);
      if (result.isNotEmpty) {
        _cacheEnToVi[text] = result;
        return result;
      }
    } catch (e) {
      print('LibreTranslate error: $e');
    }

    return text; // Return original text nếu tất cả lỗi
  }

  /// Google Translate: Anh -> Việt
  static Future<String> _googleTranslateToVietnamese(String text) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_googleUrl?client=gtx&sl=en&tl=vi&dt=t&q=${Uri.encodeComponent(text)}',
            ),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        // Parse Google's response format: [[[translated_text,original_text,...],...],...]
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is List && decoded.isNotEmpty) {
            final translations = decoded[0];
            if (translations is List && translations.isNotEmpty) {
              final firstTranslation = translations[0];
              if (firstTranslation is List && firstTranslation.isNotEmpty) {
                return firstTranslation[0] as String;
              }
            }
          }
        } catch (e) {
          print('Parse error: $e');
        }
      }
    } catch (e) {
      print('Google Translate request error: $e');
    }
    return '';
  }

  /// LibreTranslate: Anh -> Việt (Fallback)
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
