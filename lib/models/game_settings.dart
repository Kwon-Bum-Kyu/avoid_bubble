import '../config/environment_config.dart';
import '../config/game_constants.dart';

class GameSettings {
  // 게임 난이도
  double bulletSpeed; // 총알 속도
  double playerSpeed; // 플레이어 속도
  bool isInvincible; // 무적 모드 여부 (개발용)

  // 패턴 타이밍 설정
  PatternTimings patternTimings;

  // 오디오 설정
  bool soundEnabled; // 사운드 활성화 여부
  double soundVolume; // 사운드 볼륨

  // 시각적 설정
  bool showHitboxes; // 히트박스 표시 여부
  bool reducedMotion; // 모션 감소 여부

  // 생성자
  GameSettings({
    this.bulletSpeed = GameConstants.bulletSpeed,
    this.playerSpeed = GameConstants.playerSpeed,
    this.isInvincible = GameConstants.isInvincibleDefault,
    PatternTimings? patternTimings,
    this.soundEnabled = true,
    this.soundVolume = GameConstants.volumeDefault,
    this.showHitboxes = GameConstants.showHitboxesDefault,
    this.reducedMotion = false,
  }) : patternTimings = patternTimings ?? PatternTimings();

  // 현재 설정을 복사하여 새로운 인스턴스 생성
  GameSettings copyWith({
    double? bulletSpeed,
    double? playerSpeed,
    bool? isInvincible,
    PatternTimings? patternTimings,
    bool? soundEnabled,
    double? soundVolume,
    bool? showHitboxes,
    bool? reducedMotion,
  }) {
    return GameSettings(
      bulletSpeed: EnvironmentConfig.isDeveloperModeEnabled
          ? (bulletSpeed ?? this.bulletSpeed)
          : this.bulletSpeed, // 프로덕션에서는 기존 값 유지
      playerSpeed: EnvironmentConfig.isDeveloperModeEnabled
          ? (playerSpeed ?? this.playerSpeed)
          : this.playerSpeed, // 프로덕션에서는 기존 값 유지
      isInvincible: EnvironmentConfig.isDeveloperModeEnabled
          ? (isInvincible ?? this.isInvincible)
          : false, // 프로덕션에서는 항상 false
      patternTimings: EnvironmentConfig.isDeveloperModeEnabled
          ? (patternTimings ?? this.patternTimings)
          : this.patternTimings, // 프로덕션에서는 기존 값 유지
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      showHitboxes: showHitboxes ?? this.showHitboxes,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  // 기본 설정으로 리셋
  static GameSettings defaultSettings() {
    return GameSettings();
  }

  // 개발용 디버그 설정 (로컬 빌드에서만 작동)
  static GameSettings debugSettings() {
    if (!EnvironmentConfig.isDeveloperModeEnabled) {
      return defaultSettings(); // 프로덕션에서는 기본 설정 반환
    }

    return GameSettings(
      isInvincible: DebugConstants.isInvincible,
      showHitboxes: DebugConstants.showHitboxes,
      bulletSpeed: DebugConstants.bulletSpeed,
      playerSpeed: DebugConstants.playerSpeed,
      patternTimings: PatternTimings(
        pattern1StartTime: DebugConstants.pattern1StartTime,
        pattern1EndTime: DebugConstants.pattern1EndTime,
        pattern1Interval: DebugConstants.pattern1Interval,
        pattern1FastInterval: DebugConstants.pattern1FastInterval,
        pattern2StartTime: DebugConstants.pattern2StartTime,
        pattern2Interval: DebugConstants.pattern2Interval,
        pattern3StartTime: DebugConstants.pattern3StartTime,
        pattern3Interval: DebugConstants.pattern3Interval,
      ),
    );
  }

  /// 개발자 모드가 활성화되어 있는지 확인
  static bool get isDeveloperModeAvailable =>
      EnvironmentConfig.isDeveloperModeEnabled;

  /// 현재 빌드 환경 정보
  static String get buildEnvironment => EnvironmentConfig.environmentName;
}

// 총알 패턴의 타이밍을 관리하는 클래스
class PatternTimings {
  // 패턴 1 설정
  double pattern1StartTime; // 시작 시간
  double pattern1EndTime; // 종료 시간
  double pattern1Interval; // 생성 간격
  double pattern1FastInterval; // 빠른 생성 간격

  // 패턴 2 설정
  double pattern2StartTime;
  double pattern2Interval;

  // 패턴 3 설정
  double pattern3StartTime;
  double pattern3Interval;

  // 생성자
  PatternTimings({
    this.pattern1StartTime = GameConstants.pattern1StartTimeDefault,
    this.pattern1EndTime = GameConstants.pattern1EndTimeDefault,
    this.pattern1Interval = GameConstants.pattern1IntervalDefault,
    this.pattern1FastInterval = GameConstants.pattern1FastIntervalDefault,
    this.pattern2StartTime = GameConstants.pattern2StartTimeDefault,
    this.pattern2Interval = GameConstants.pattern2IntervalDefault,
    this.pattern3StartTime = GameConstants.pattern3StartTimeDefault,
    this.pattern3Interval = GameConstants.pattern3IntervalDefault,
  });

  // 현재 타이밍을 복사하여 새로운 인스턴스를 만드는 메서드
  PatternTimings copyWith({
    double? pattern1StartTime,
    double? pattern1EndTime,
    double? pattern1Interval,
    double? pattern1FastInterval,
    double? pattern2StartTime,
    double? pattern2Interval,
    double? pattern3StartTime,
    double? pattern3Interval,
  }) {
    return PatternTimings(
      pattern1StartTime: pattern1StartTime ?? this.pattern1StartTime,
      pattern1EndTime: pattern1EndTime ?? this.pattern1EndTime,
      pattern1Interval: pattern1Interval ?? this.pattern1Interval,
      pattern1FastInterval: pattern1FastInterval ?? this.pattern1FastInterval,
      pattern2StartTime: pattern2StartTime ?? this.pattern2StartTime,
      pattern2Interval: pattern2Interval ?? this.pattern2Interval,
      pattern3StartTime: pattern3StartTime ?? this.pattern3StartTime,
      pattern3Interval: pattern3Interval ?? this.pattern3Interval,
    );
  }
}
