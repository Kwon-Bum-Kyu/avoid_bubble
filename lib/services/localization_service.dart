import 'package:flutter/widgets.dart';

class LocalizationService {
  static String _currentLanguage = 'ko'; // 기본값: 한국어

  static String get currentLanguage => _currentLanguage;

  /// 브라우저 언어를 감지하여 언어 설정
  static void detectBrowserLanguage() {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final languageCode = locale.languageCode.toLowerCase();
      
      // 지원 언어: 한국어(ko), 영어(en)
      if (languageCode == 'en') {
        _currentLanguage = 'en';
      } else {
        _currentLanguage = 'ko'; // 기본값
      }
    } catch (e) {
      _currentLanguage = 'ko'; // 오류 시 한국어로 기본 설정
    }
  }

  /// 언어 수동 변경
  static void setLanguage(String languageCode) {
    if (languageCode == 'en' || languageCode == 'ko') {
      _currentLanguage = languageCode;
    }
  }

  /// 다국어 텍스트 반환
  static String getText(String key) {
    return _texts[key]?[_currentLanguage] ?? _texts[key]?['ko'] ?? key;
  }

  // 다국어 텍스트 데이터
  static const Map<String, Map<String, String>> _texts = {
    // 시작 화면
    'start_title': {
      'ko': '어보이드 버블',
      'en': 'Avoid Bubble',
    },
    'start_subtitle': {
      'ko': '무한 속도 증가 서바이벌 게임',
      'en': 'Infinite Speed Survival Game',
    },
    'start_best_time': {
      'ko': '최고 기록: {}초',
      'en': 'Best Time: {}s',
    },
    'start_games_played': {
      'ko': '총 게임 횟수: {}회',
      'en': 'Games Played: {} times',
    },
    'start_most_common_grade': {
      'ko': '최다 등급: {}',
      'en': 'Most Common Grade: {}',
    },
    'start_game': {
      'ko': '게임 시작',
      'en': 'Start Game',
    },
    'start_view_ranking': {
      'ko': '랭킹 보기',
      'en': 'View Ranking',
    },
    'start_controls': {
      'ko': 'WASD / 방향키 - 이동 | R - 재시작 | ESC - 메인 메뉴',
      'en': 'WASD / Arrow Keys - Move | R - Restart | ESC - Main Menu',
    },

    // 설정 화면
    'settings_title': {
      'ko': '설정',
      'en': 'Settings',
    },
    'settings_game_difficulty': {
      'ko': '게임 난이도',
      'en': 'Game Difficulty',
    },
    'settings_bullet_speed': {
      'ko': '총알 속도',
      'en': 'Bullet Speed',
    },
    'settings_player_speed': {
      'ko': '플레이어 속도',
      'en': 'Player Speed',
    },
    'settings_invincible_mode': {
      'ko': '무적 모드',
      'en': 'Invincible Mode',
    },
    'settings_pattern_timings': {
      'ko': '패턴 타이밍',
      'en': 'Pattern Timings',
    },
    'settings_pattern1_start': {
      'ko': '패턴 1 시작 시간',
      'en': 'Pattern 1 Start Time',
    },
    'settings_pattern2_start': {
      'ko': '패턴 2 시작 시간',
      'en': 'Pattern 2 Start Time',
    },
    'settings_pattern3_start': {
      'ko': '패턴 3 시작 시간',
      'en': 'Pattern 3 Start Time',
    },
    'settings_visual_audio': {
      'ko': '비주얼 및 오디오',
      'en': 'Visual & Audio',
    },
    'settings_show_hitboxes': {
      'ko': '히트박스 표시',
      'en': 'Show Hitboxes',
    },
    'settings_hitbox_info': {
      'ko': '히트박스 표시 여부',
      'en': 'Toggle hitbox visibility',
    },
    'settings_sound_effects': {
      'ko': '소리 효과',
      'en': 'Sound Effects',
    },
    'settings_sound': {
      'ko': '소리',
      'en': 'Sound',
    },
    'settings_build_info': {
      'ko': '빌드 정보',
      'en': 'Build Info',
    },
    'settings_environment': {
      'ko': '환경: {}',
      'en': 'Environment: {}',
    },
    'settings_dev_features_enabled': {
      'ko': '개발자 기능 활성화',
      'en': 'Developer Features Enabled',
    },
    'settings_production_mode': {
      'ko': '프로덕션 모드',
      'en': 'Production Mode',
    },
    'settings_debug_mode': {
      'ko': '디버그 모드: {}',
      'en': 'Debug Mode: {}',
    },
    'settings_reset_to_default': {
      'ko': '기본값으로 리셋',
      'en': 'Reset to Default',
    },
    'settings_save_settings': {
      'ko': '설정 저장',
      'en': 'Save Settings',
    },
    'settings_hide_hitboxes': {
      'ko': '히트박스 숨기기',
      'en': 'Hide Hitboxes',
    },
    'settings_show_hitboxes_toggle': {
      'ko': '히트박스 표시',
      'en': 'Show Hitboxes',
    },

    // 게임 오버 화면
    'game_over_title': {
      'ko': '게임 오버',
      'en': 'Game Over',
    },
    'game_over_survival_time': {
      'ko': '생존 시간',
      'en': 'Survival Time',
    },
    'game_over_time_unit': {
      'ko': '{}초',
      'en': '{}s',
    },
    'game_over_grade': {
      'ko': '등급: {}',
      'en': 'Grade: {}',
    },
    'game_over_new_best_record': {
      'ko': '새로운 최고 기록!',
      'en': 'New Best Record!',
    },
    'game_over_current_rank': {
      'ko': '현재 랭킹: {}위',
      'en': 'Current Rank: #{}',
    },
    'game_over_challenge_ranking': {
      'ko': '랭킹 도전!',
      'en': 'Challenge Ranking!',
    },
    'game_over_register_nickname_prompt': {
      'ko': '랭킹에 도전하려면 닉네임 등록이 필요합니다',
      'en': 'Nickname registration required to challenge ranking',
    },
    'game_over_register_nickname_button': {
      'ko': '닉네임 등록',
      'en': 'Register Nickname',
    },
    'game_over_restart': {
      'ko': '다시 시도',
      'en': 'Try Again',
    },
    'game_over_menu': {
      'ko': '메뉴로',
      'en': 'Main Menu',
    },
    'game_over_view_ranking': {
      'ko': '랭킹 보기',
      'en': 'View Ranking',
    },

    // 랭킹 화면
    'ranking_title': {
      'ko': '랭킹',
      'en': 'Ranking',
    },
    'ranking_load_failed': {
      'ko': '랭킹 불러오기 실패',
      'en': 'Failed to load ranking',
    },
    'ranking_all': {
      'ko': '전체 랭킹',
      'en': 'All Rankings',
    },
    'ranking_my_records': {
      'ko': '내 기록',
      'en': 'My Records',
    },
    'ranking_no_records': {
      'ko': '아직 기록이 없습니다',
      'en': 'No records yet',
    },
    'ranking_refresh': {
      'ko': '새로고침',
      'en': 'Refresh',
    },
    'ranking_me': {
      'ko': '나',
      'en': 'Me',
    },
    'ranking_survival_time': {
      'ko': '생존 시간: {}초',
      'en': 'Survival Time: {}s',
    },
    'ranking_register_prompt': {
      'ko': '내 기록을 보려면 닉네임 등록이 필요합니다',
      'en': 'Nickname registration required to view your records',
    },
    'ranking_no_my_records': {
      'ko': '아직 내 기록이 없습니다',
      'en': 'No personal records yet',
    },
    'ranking_best': {
      'ko': '최고',
      'en': 'Best',
    },
    'ranking_no_date': {
      'ko': '날짜 없음',
      'en': 'No Date',
    },

    // 닉네임 등록 화면
    'nickname_title': {
      'ko': '닉네임 등록',
      'en': 'Register Nickname',
    },
    'nickname_subtitle': {
      'ko': '랭킹에 도전하실 닉네임을 입력해주세요',
      'en': 'Enter your nickname to challenge the ranking',
    },
    'nickname_hint': {
      'ko': '닉네임을 입력해주세요',
      'en': 'Enter your nickname',
    },
    'nickname_rules': {
      'ko': '• 2-10자 이내\n• 한글, 영문, 숫자 가능\n• 특수문자 사용 불가',
      'en': '• 2-10 characters\n• Korean, English, numbers allowed\n• No special characters',
    },
    'nickname_later': {
      'ko': '나중에',
      'en': 'Later',
    },
    'nickname_register': {
      'ko': '등록',
      'en': 'Register',
    },
    'nickname_network_error': {
      'ko': '네트워크 오류가 발생했습니다',
      'en': 'A network error occurred',
    },

    // 공통
    'active': {
      'ko': '활성',
      'en': 'Active',
    },
    'inactive': {
      'ko': '비활성',
      'en': 'Inactive',
    },
  };

  /// 포맷팅이 필요한 텍스트 처리
  static String getFormattedText(String key, List<dynamic> args) {
    String template = getText(key);
    
    for (int i = 0; i < args.length; i++) {
      template = template.replaceFirst('{}', args[i].toString());
    }
    
    return template;
  }
}