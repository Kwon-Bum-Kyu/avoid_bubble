import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';

class SettingsService {
  static const String _settingsKey = 'game_settings';
  static SettingsService? _instance;
  SharedPreferences? _prefs;
  GameSettings _currentSettings = GameSettings.defaultSettings();

  // 싱글톤 패턴
  static SettingsService get instance {
    _instance ??= SettingsService._internal();
    return _instance!;
  }

  SettingsService._internal();

  // 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  // 현재 설정 가져오기
  GameSettings get currentSettings => _currentSettings;

  // 설정 로드
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs?.getString(_settingsKey);
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(settingsJson);
        _currentSettings = _gameSettingsFromJson(settingsMap);
      }
    } catch (e) {
      // 로드 실패 시 기본 설정 사용
      _currentSettings = GameSettings.defaultSettings();
    }
  }

  // 설정 저장
  Future<void> saveSettings(GameSettings settings) async {
    try {
      _currentSettings = settings;
      final settingsJson = json.encode(_gameSettingsToJson(settings));
      await _prefs?.setString(_settingsKey, settingsJson);
    } catch (e) {
      // 저장 실패 처리
      throw Exception('Failed to save settings: $e');
    }
  }

  // 설정 업데이트 (부분 업데이트)
  Future<void> updateSettings({
    double? bulletSpeed,
    double? playerSpeed,
    bool? isInvincible,
    PatternTimings? patternTimings,
    bool? soundEnabled,
    double? soundVolume,
    bool? showHitboxes,
    bool? reducedMotion,
  }) async {
    final updatedSettings = _currentSettings.copyWith(
      bulletSpeed: bulletSpeed,
      playerSpeed: playerSpeed,
      isInvincible: isInvincible,
      patternTimings: patternTimings,
      soundEnabled: soundEnabled,
      soundVolume: soundVolume,
      showHitboxes: showHitboxes,
      reducedMotion: reducedMotion,
    );

    await saveSettings(updatedSettings);
  }

  // 기본 설정으로 리셋
  Future<void> resetToDefaults() async {
    await saveSettings(GameSettings.defaultSettings());
  }

  // 디버그 설정 적용
  Future<void> applyDebugSettings() async {
    await saveSettings(GameSettings.debugSettings());
  }

  // GameSettings를 JSON으로 변환
  Map<String, dynamic> _gameSettingsToJson(GameSettings settings) {
    return {
      'bulletSpeed': settings.bulletSpeed,
      'playerSpeed': settings.playerSpeed,
      'isInvincible': settings.isInvincible,
      'soundEnabled': settings.soundEnabled,
      'soundVolume': settings.soundVolume,
      'showHitboxes': settings.showHitboxes,
      'reducedMotion': settings.reducedMotion,
      'patternTimings': {
        'pattern1StartTime': settings.patternTimings.pattern1StartTime,
        'pattern1EndTime': settings.patternTimings.pattern1EndTime,
        'pattern1Interval': settings.patternTimings.pattern1Interval,
        'pattern1FastInterval': settings.patternTimings.pattern1FastInterval,
        'pattern2StartTime': settings.patternTimings.pattern2StartTime,
        'pattern2Interval': settings.patternTimings.pattern2Interval,
        'pattern3StartTime': settings.patternTimings.pattern3StartTime,
        'pattern3Interval': settings.patternTimings.pattern3Interval,
      },
    };
  }

  // JSON에서 GameSettings로 변환
  GameSettings _gameSettingsFromJson(Map<String, dynamic> json) {
    final patternTimingsJson = json['patternTimings'] as Map<String, dynamic>?;

    return GameSettings(
      bulletSpeed: (json['bulletSpeed'] as num?)?.toDouble() ?? GameSettings.defaultSettings().bulletSpeed,
      playerSpeed: (json['playerSpeed'] as num?)?.toDouble() ?? GameSettings.defaultSettings().playerSpeed,
      isInvincible: json['isInvincible'] as bool? ?? GameSettings.defaultSettings().isInvincible,
      soundEnabled: json['soundEnabled'] as bool? ?? GameSettings.defaultSettings().soundEnabled,
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? GameSettings.defaultSettings().soundVolume,
      showHitboxes: json['showHitboxes'] as bool? ?? GameSettings.defaultSettings().showHitboxes,
      reducedMotion: json['reducedMotion'] as bool? ?? GameSettings.defaultSettings().reducedMotion,
      patternTimings: patternTimingsJson != null
          ? PatternTimings(
              pattern1StartTime: (patternTimingsJson['pattern1StartTime'] as num?)?.toDouble() ??
                GameSettings.defaultSettings().patternTimings.pattern1StartTime,
              pattern1EndTime: (patternTimingsJson['pattern1EndTime'] as num?)?.toDouble() ??
                GameSettings.defaultSettings().patternTimings.pattern1EndTime,
              pattern1Interval: (patternTimingsJson['pattern1Interval'] as num?)?.toDouble() ??
                GameSettings.defaultSettings().patternTimings.pattern1Interval,
              pattern1FastInterval: (patternTimingsJson['pattern1FastInterval'] as num?)?.toDouble() ??
                GameSettings.defaultSettings().patternTimings.pattern1FastInterval,
              pattern2StartTime: (patternTimingsJson['pattern2StartTime'] as num?)?.toDouble() ??
                GameSettings.defaultSettings().patternTimings.pattern2StartTime,
              pattern2Interval: (patternTimingsJson['pattern2Interval'] as num?)?.toDouble() ??
                GameSettings.defaultSettings().patternTimings.pattern2Interval,
              pattern3StartTime: (patternTimingsJson['pattern3StartTime'] as num?)?.toDouble() ??
                GameSettings.defaultSettings().patternTimings.pattern3StartTime,
              pattern3Interval: (patternTimingsJson['pattern3Interval'] as num?)?.toDouble() ??
                GameSettings.defaultSettings().patternTimings.pattern3Interval,
            )
          : GameSettings.defaultSettings().patternTimings,
    );
  }
}