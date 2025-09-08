import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

class LocalizationService {
  static String _currentLanguage = 'en'; // 기본값: 영어
  static Map<String, String> _localizedStrings = {};
  static bool _isInitialized = false;

  static String get currentLanguage => _currentLanguage;
  static bool get isInitialized => _isInitialized;

  /// 브라우저 언어를 감지하여 언어 설정
  static void detectBrowserLanguage() {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final languageCode = locale.languageCode.toLowerCase();
      // 지원 언어: 한국어(ko), 영어(en)
      if (languageCode == 'ko') {
        _currentLanguage = 'ko';
      } else {
        _currentLanguage = 'en'; // 기본값
      }
    } catch (e) {
      _currentLanguage = 'en'; // 오류 시 영어로 기본 설정
    }
  }

  /// 언어별 ARB 파일 로드
  static Future<void> loadLanguage() async {
    try {
      final jsonString =
          await rootBundle.loadString('lib/l10n/app_$_currentLanguage.arb');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // ARB 파일에서 메타데이터(@로 시작하는 키) 제거
      _localizedStrings = <String, String>{};
      jsonMap.forEach((key, value) {
        if (!key.startsWith('@') && value is String) {
          _localizedStrings[key] = value;
        }
      });
      _isInitialized = true;
    } catch (e) {
      // 로드 실패 시 기본 영어 파일 시도
      if (_currentLanguage != 'en') {
        try {
          final jsonString = await rootBundle.loadString('lib/l10n/app_en.arb');
          final Map<String, dynamic> jsonMap = json.decode(jsonString);
          _localizedStrings = <String, String>{};
          jsonMap.forEach((key, value) {
            if (!key.startsWith('@') && value is String) {
              _localizedStrings[key] = value;
            }
          });
          _isInitialized = true;
        } catch (e2) {
          throw Exception('Failed to load localization files');
        }
      } else {
        throw Exception('Failed to load localization files');
      }
    }
  }

  /// 언어 수동 변경
  static Future<void> setLanguage(String languageCode) async {
    if (languageCode == 'en' || languageCode == 'ko') {
      _currentLanguage = languageCode;
      _isInitialized = false;
      await loadLanguage();
    }
  }

  /// 다국어 텍스트 반환
  static String getText(String key) {
    if (!_isInitialized) {
      // 초기화되지 않은 경우 키를 그대로 반환
      return key;
    }
    return _localizedStrings[key] ?? key;
  }

  /// 포맷팅이 필요한 텍스트 처리
  static String getFormattedText(String key, List<dynamic> args) {
    String template = getText(key);

    for (int i = 0; i < args.length; i++) {
      template = template.replaceFirst(
          '{${_getPlaceholderName(key, i)}}', args[i].toString());
    }

    return template;
  }

  /// 플레이스홀더 이름 매핑
  static String _getPlaceholderName(String key, int index) {
    const placeholderMap = {
      'start_best_time': ['time'],
      'start_games_played': ['count'],
      'start_most_common_grade': ['grade'],
      'settings_environment': ['env'],
      'settings_debug_mode': ['status'],
      'game_over_time_unit': ['time'],
      'game_over_grade': ['grade'],
      'game_over_current_rank': ['rank'],
      'ranking_survival_time': ['time'],
    };

    final placeholders = placeholderMap[key];
    if (placeholders != null && index < placeholders.length) {
      return placeholders[index];
    }
    return index.toString();
  }
}
