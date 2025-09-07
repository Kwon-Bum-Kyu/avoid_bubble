// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get title => '버블 피하기';

  @override
  String get startScreen_title => '버블 피하기';

  @override
  String get startScreen_subtitle => '탄막을 피해 최대한 오래 생존하세요!';

  @override
  String startScreen_bestTime(Object time) {
    return '최고 기록: $time초';
  }

  @override
  String startScreen_gamesPlayed(Object count) {
    return '플레이한 게임: $count판';
  }

  @override
  String startScreen_mostCommonGrade(Object grade) {
    return '가장 많이 받은 등급: $grade';
  }

  @override
  String get startScreen_startGame => '게임 시작';

  @override
  String get startScreen_viewRanking => '랭킹 보기';

  @override
  String get start_screen_controls => '조작법: WASD 또는 방향키로 이동';

  @override
  String get gameOver_title => '게임 오버';

  @override
  String get gameOver_survivalTime => '생존 시간';

  @override
  String gameOver_timeUnit(Object time) {
    return '$time초';
  }

  @override
  String gameOver_grade(Object grade) {
    return '등급 $grade';
  }

  @override
  String get gameOver_newBestRecord => '새로운 최고 기록!';

  @override
  String gameOver_currentRank(Object rank) {
    return '현재 순위: $rank위';
  }

  @override
  String get gameOver_challengeRanking => '랭킹에 도전하세요!';

  @override
  String get gameOver_registerNicknamePrompt => '닉네임을 등록하면 기록이 랭킹에 등록됩니다.';

  @override
  String get gameOver_registerNicknameButton => '닉네임 등록하기';

  @override
  String get gameOver_restart => '다시 시작';

  @override
  String get gameOver_menu => '메뉴';

  @override
  String get gameOver_viewRanking => '랭킹 보기';

  @override
  String get nickname_title => '닉네임 등록';

  @override
  String get nickname_subtitle => '랭킹 등록을 위해 닉네임을 설정해주세요';

  @override
  String get nickname_hint => '닉네임 입력 (2-12자)';

  @override
  String get nickname_networkError => '네트워크 오류가 발생했습니다.';

  @override
  String get nickname_rules => '• 한글, 영문, 숫자만 사용 가능\n• 2-12자로 입력해주세요\n• 중복된 닉네임은 사용할 수 없습니다';

  @override
  String get nickname_later => '나중에';

  @override
  String get nickname_register => '등록하기';

  @override
  String get ranking_title => '🏆 랭킹';

  @override
  String get ranking_all => '전체';

  @override
  String get ranking_myRecords => '내 기록';

  @override
  String get ranking_loadFailed => '랭킹 데이터 로드에 실패했습니다.';

  @override
  String get ranking_noRecords => '아직 등록된 기록이 없습니다.';

  @override
  String get ranking_refresh => '새로고침';

  @override
  String get ranking_me => '나';

  @override
  String ranking_survivalTime(Object time) {
    return '생존 시간: $time초';
  }

  @override
  String get ranking_registerPrompt => '닉네임을 등록하면 내 기록을 확인할 수 있습니다.';

  @override
  String get ranking_noMyRecords => '아직 등록된 기록이 없습니다.\n게임을 플레이해보세요!';

  @override
  String get ranking_best => '최고 기록';

  @override
  String get ranking_noDate => '날짜 정보 없음';

  @override
  String get settings_title => '설정';

  @override
  String get settings_gameDifficulty => '게임 난이도 (개발자 모드)';

  @override
  String get settings_bulletSpeed => '총알 속도';

  @override
  String get settings_playerSpeed => '플레이어 속도';

  @override
  String get settings_invincibleMode => '무적 모드';

  @override
  String get settings_patternTimings => '패턴 시간 (개발자 모드)';

  @override
  String get settings_pattern1Start => '패턴 1 시작 (초)';

  @override
  String get settings_pattern2Start => '패턴 2 시작 (초)';

  @override
  String get settings_pattern3Start => '패턴 3 시작 (초)';

  @override
  String get settings_visualAudio => '시각 및 오디오';

  @override
  String get settings_showHitboxes => '히트박스 표시 (개발자 전용)';

  @override
  String get settings_hitboxInfo => '• 플레이어: 초록색 원\n• 모든 탄막: 빨간색 원';

  @override
  String get settings_soundEffects => '사운드 효과';

  @override
  String get settings_sound => '사운드';

  @override
  String get settings_buildInfo => '빌드 정보';

  @override
  String settings_environment(Object env) {
    return '환경: $env';
  }

  @override
  String get settings_devFeaturesEnabled => '개발자 기능이 활성화되어 있습니다.';

  @override
  String get settings_productionMode => '프로덕션 모드로 실행 중입니다.';

  @override
  String settings_debugMode(Object mode) {
    return '디버그 모드: $mode';
  }

  @override
  String get settings_resetToDefault => '기본값으로 재설정';

  @override
  String get settings_saveSettings => '설정 저장';

  @override
  String get settings_hideHitboxes => '히트박스 숨기기';

  @override
  String get settings_showHitboxesToggle => '히트박스 표시';
}
