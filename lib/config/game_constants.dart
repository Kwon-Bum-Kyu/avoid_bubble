// 게임 전역 상수 정의
class GameConstants {
  // ===== 플레이어 관련 상수 =====

  // 플레이어 속도 설정
  static const double playerSpeedMin = 200.0; // 설정 최소값
  static const double playerSpeedMax = 500.0; // 설정 최대값
  static const double playerSpeed = 300.0; // 기본값

  // ===== 총알 관련 상수 =====

  // 총알 속도 설정
  static const double bulletSpeedMin = 20.0; // 설정 최소값
  static const double bulletSpeedMax = 200.0; // 설정 최대값
  static const double bulletSpeed = 100.0; // 총알속도

  // 총알 크기 및 충돌
  static const double bulletRadius = 24.0; // 총알 지름 (1440x720 기준 기본값)

  // ===== 게임 패턴 타이밍 상수 =====

  // Pattern 1: Targeted Bullets
  static const double pattern1StartTimeDefault = 2.0; // 패턴1 시작 시간
  static const double pattern1IntervalDefault = 1.0; // 패턴1 발사 간격
  static const double pattern1FastIntervalDefault = 0.8; // 패턴1 빠른 간격
  static const double pattern1EndTimeDefault = 15.0; // 패턴1 종료 시간

  // Pattern 2: Eight Direction Attack
  static const double pattern2StartTimeDefault = 15.0; // 패턴2 시작 시간
  static const double pattern2IntervalDefault = 5.0; // 패턴2 발사 간격

  // Pattern 3: Sequential Linear Barrage
  static const double pattern3StartTimeDefault = 30.0; // 패턴3 시작 시간
  static const double pattern3IntervalDefault = 10.0; // 패턴3 발사 간격

  // 패턴 설정 범위
  static const double patternStartTimeMin = 0.5; // 시작 시간 최소값
  static const double patternStartTimeMax = 60.0; // 시작 시간 최대값
  static const double patternIntervalMin = 0.3; // 간격 최소값
  static const double patternIntervalMax = 15.0; // 간격 최대값

  // ===== 오디오 관련 상수 =====

  // 볼륨 설정
  static const double volumeMin = 0.0; // 최소 볼륨
  static const double volumeMax = 1.0; // 최대 볼륨
  static const double volumeDefault = 0.5; // 기본 볼륨
  static const double volumeIncrement = 0.1; // 볼륨 증감 단위

  // ===== 게임플레이 상수 =====

  // 게임 화면 설정
  static const double gameScreenPadding = 20.0; // 화면 패딩
  static const double gameButtonSize = 50.0; // 버튼 크기

  // 히트박스 시각화
  static const double hitboxOpacity = 0.3; // 히트박스 투명도
  static const double hitboxStrokeWidth = 1.0; // 히트박스 테두리 두께
  static const double hitboxCenterDotSize = 2.0; // 중심점 크기

  // ===== 애니메이션 상수 =====

  // 스프라이트 애니메이션
  static const int walkAnimationFrames = 8; // 걷기 애니메이션 프레임 수
  static const double walkAnimationStepTime = 0.08; // 걷기 애니메이션 프레임 시간
  static const int idleAnimationFrames = 1; // 정지 애니메이션 프레임 수
  static const double idleAnimationStepTime = 1.0; // 정지 애니메이션 프레임 시간

  // ===== 디버그 모드 상수 =====

  // 디버그 설정
  static const bool debugModeDefault = false; // 기본 디버그 모드 상태
  static const bool showHitboxesDefault = false; // 기본 히트박스 표시 상태
  static const bool isInvincibleDefault = false; // 기본 무적 모드 상태

  // ===== 화면 크기 관련 =====

  // 최소 화면 크기
  static const double minScreenWidth = 320.0; // 최소 화면 너비
  static const double minScreenHeight = 480.0; // 최소 화면 높이

  // ===== 기타 상수 =====

  // 게임 통계
  static const String defaultPlayerGrade = 'F'; // 기본 등급
  static const int defaultBulletsAvoided = 0; // 기본 회피 총알 수

  // 설정 키 이름들
  static const String settingsKeyPlayerSpeed = 'player_speed';
  static const String settingsKeyBulletSpeed = 'bullet_speed';
  static const String settingsKeyVolume = 'volume';
  static const String settingsKeyDebugMode = 'debug_mode';
  static const String settingsKeyShowHitboxes = 'show_hitboxes';
  static const String settingsKeyIsInvincible = 'is_invincible';

  // 게임 상태
  static const String gameStateStartScreen = 'start_screen';
  static const String gameStateSettings = 'settings';
  static const String gameStatePlaying = 'playing';
  static const String gameStateGameOver = 'game_over';
  static const String gameStateRanking = 'ranking';
}

// 디버그 설정을 위한 편의 클래스
class DebugConstants {
  // 디버그 모드에서 사용할 설정값들
  static const double playerSpeed = GameConstants.playerSpeed;
  static const double bulletSpeed = GameConstants.bulletSpeed;
  static const bool debugMode = true;
  static const bool showHitboxes = true;
  static const bool isInvincible = false; // 디버그에서도 기본적으로는 무적 모드 끔

  // 디버그용 패턴 타이밍 (더 빨리 테스트)
  static const double pattern1StartTime = 1.0;
  static const double pattern1Interval = 0.5;
  static const double pattern1FastInterval = 0.3;
  static const double pattern1EndTime = 8.0;
  static const double pattern2StartTime = 8.0;
  static const double pattern2Interval = 3.0;
  static const double pattern3StartTime = 15.0;
  static const double pattern3Interval = 5.0;
}
