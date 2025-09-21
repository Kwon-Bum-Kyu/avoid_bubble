import 'package:flutter/foundation.dart';
import '../models/game_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService.instance;
  bool _isInitialized = false;

  // 초기화 상태
  bool get isInitialized => _isInitialized;

  // 현재 설정 가져오기
  GameSettings get currentSettings => _settingsService.currentSettings;

  // 초기화
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _settingsService.initialize();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // 설정 업데이트
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
    await _settingsService.updateSettings(
      bulletSpeed: bulletSpeed,
      playerSpeed: playerSpeed,
      isInvincible: isInvincible,
      patternTimings: patternTimings,
      soundEnabled: soundEnabled,
      soundVolume: soundVolume,
      showHitboxes: showHitboxes,
      reducedMotion: reducedMotion,
    );
    notifyListeners();
  }

  // 특정 값 업데이트 메서드들
  Future<void> updateBulletSpeed(double speed) async {
    await updateSettings(bulletSpeed: speed);
  }

  Future<void> updatePlayerSpeed(double speed) async {
    await updateSettings(playerSpeed: speed);
  }

  Future<void> toggleInvincible() async {
    await updateSettings(isInvincible: !currentSettings.isInvincible);
  }

  Future<void> toggleSound() async {
    await updateSettings(soundEnabled: !currentSettings.soundEnabled);
  }

  Future<void> updateSoundVolume(double volume) async {
    await updateSettings(soundVolume: volume);
  }

  Future<void> toggleHitboxes() async {
    await updateSettings(showHitboxes: !currentSettings.showHitboxes);
  }

  Future<void> toggleReducedMotion() async {
    await updateSettings(reducedMotion: !currentSettings.reducedMotion);
  }

  // 패턴 타이밍 업데이트
  Future<void> updatePatternTimings(PatternTimings newTimings) async {
    await updateSettings(patternTimings: newTimings);
  }

  Future<void> updatePattern1StartTime(double time) async {
    final newTimings = currentSettings.patternTimings.copyWith(
      pattern1StartTime: time,
    );
    await updatePatternTimings(newTimings);
  }

  Future<void> updatePattern1EndTime(double time) async {
    final newTimings = currentSettings.patternTimings.copyWith(
      pattern1EndTime: time,
    );
    await updatePatternTimings(newTimings);
  }

  Future<void> updatePattern1Interval(double interval) async {
    final newTimings = currentSettings.patternTimings.copyWith(
      pattern1Interval: interval,
    );
    await updatePatternTimings(newTimings);
  }

  Future<void> updatePattern1FastInterval(double interval) async {
    final newTimings = currentSettings.patternTimings.copyWith(
      pattern1FastInterval: interval,
    );
    await updatePatternTimings(newTimings);
  }

  Future<void> updatePattern2StartTime(double time) async {
    final newTimings = currentSettings.patternTimings.copyWith(
      pattern2StartTime: time,
    );
    await updatePatternTimings(newTimings);
  }

  Future<void> updatePattern2Interval(double interval) async {
    final newTimings = currentSettings.patternTimings.copyWith(
      pattern2Interval: interval,
    );
    await updatePatternTimings(newTimings);
  }

  Future<void> updatePattern3StartTime(double time) async {
    final newTimings = currentSettings.patternTimings.copyWith(
      pattern3StartTime: time,
    );
    await updatePatternTimings(newTimings);
  }

  Future<void> updatePattern3Interval(double interval) async {
    final newTimings = currentSettings.patternTimings.copyWith(
      pattern3Interval: interval,
    );
    await updatePatternTimings(newTimings);
  }

  // 기본 설정으로 리셋
  Future<void> resetToDefaults() async {
    await _settingsService.resetToDefaults();
    notifyListeners();
  }

  // 디버그 설정 적용
  Future<void> applyDebugSettings() async {
    await _settingsService.applyDebugSettings();
    notifyListeners();
  }

  // 설정 저장 (명시적)
  Future<void> saveCurrentSettings() async {
    await _settingsService.saveSettings(currentSettings);
  }

  // 새로운 설정 저장 (외부에서 받은 설정)
  Future<void> saveSettings(GameSettings settings) async {
    await _settingsService.saveSettings(settings);
    notifyListeners();
  }
}