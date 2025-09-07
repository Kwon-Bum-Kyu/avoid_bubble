// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Avoid Bubble';

  @override
  String get startScreen_title => 'Avoid Bubble';

  @override
  String get startScreen_subtitle => 'Survive as long as you can!';

  @override
  String startScreen_bestTime(Object time) {
    return 'Best Time: ${time}s';
  }

  @override
  String startScreen_gamesPlayed(Object count) {
    return 'Games Played: $count';
  }

  @override
  String startScreen_mostCommonGrade(Object grade) {
    return 'Most Common Grade: $grade';
  }

  @override
  String get startScreen_startGame => 'Start Game';

  @override
  String get startScreen_viewRanking => 'View Ranking';

  @override
  String get start_screen_controls => 'Controls: WASD or Arrow keys to move';

  @override
  String get gameOver_title => 'GAME OVER';

  @override
  String get gameOver_survivalTime => 'Survival Time';

  @override
  String gameOver_timeUnit(Object time) {
    return '${time}s';
  }

  @override
  String gameOver_grade(Object grade) {
    return 'Grade $grade';
  }

  @override
  String get gameOver_newBestRecord => 'New Best Record!';

  @override
  String gameOver_currentRank(Object rank) {
    return 'Current Rank: $rank';
  }

  @override
  String get gameOver_challengeRanking => 'Challenge the Ranking!';

  @override
  String get gameOver_registerNicknamePrompt => 'Register your nickname to be on the ranking.';

  @override
  String get gameOver_registerNicknameButton => 'Register Nickname';

  @override
  String get gameOver_restart => 'Restart';

  @override
  String get gameOver_menu => 'Menu';

  @override
  String get gameOver_viewRanking => 'View Ranking';

  @override
  String get nickname_title => 'Register Nickname';

  @override
  String get nickname_subtitle => 'Set your nickname for ranking registration.';

  @override
  String get nickname_hint => 'Enter nickname (2-12 chars)';

  @override
  String get nickname_networkError => 'A network error occurred.';

  @override
  String get nickname_rules => '• Korean, English, and numbers only\n• 2-12 characters long\n• Duplicate nicknames cannot be used';

  @override
  String get nickname_later => 'Later';

  @override
  String get nickname_register => 'Register';

  @override
  String get ranking_title => '🏆 Ranking';

  @override
  String get ranking_all => 'All';

  @override
  String get ranking_myRecords => 'My Records';

  @override
  String get ranking_loadFailed => 'Failed to load ranking data.';

  @override
  String get ranking_noRecords => 'No records yet.';

  @override
  String get ranking_refresh => 'Refresh';

  @override
  String get ranking_me => 'ME';

  @override
  String ranking_survivalTime(Object time) {
    return 'Survival Time: ${time}s';
  }

  @override
  String get ranking_registerPrompt => 'Register a nickname to check your records.';

  @override
  String get ranking_noMyRecords => 'No records yet.\nPlay a game!';

  @override
  String get ranking_best => 'BEST';

  @override
  String get ranking_noDate => 'No date information';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_gameDifficulty => 'Game Difficulty (Dev Mode)';

  @override
  String get settings_bulletSpeed => 'Bullet Speed';

  @override
  String get settings_playerSpeed => 'Player Speed';

  @override
  String get settings_invincibleMode => 'Invincible Mode';

  @override
  String get settings_patternTimings => 'Pattern Timings (Dev Mode)';

  @override
  String get settings_pattern1Start => 'Pattern 1 Start (s)';

  @override
  String get settings_pattern2Start => 'Pattern 2 Start (s)';

  @override
  String get settings_pattern3Start => 'Pattern 3 Start (s)';

  @override
  String get settings_visualAudio => 'Visual & Audio';

  @override
  String get settings_showHitboxes => 'Show Hitboxes (Dev Only)';

  @override
  String get settings_hitboxInfo => '• Player: Green Circle\n• All Bullets: Red Circle';

  @override
  String get settings_soundEffects => 'Sound Effects';

  @override
  String get settings_sound => 'Sound';

  @override
  String get settings_buildInfo => 'Build Info';

  @override
  String settings_environment(Object env) {
    return 'Environment: $env';
  }

  @override
  String get settings_devFeaturesEnabled => 'Developer features are enabled.';

  @override
  String get settings_productionMode => 'Running in production mode.';

  @override
  String settings_debugMode(Object mode) {
    return 'Debug Mode: $mode';
  }

  @override
  String get settings_resetToDefault => 'Reset to Default';

  @override
  String get settings_saveSettings => 'Save Settings';

  @override
  String get settings_hideHitboxes => 'Hide Hitboxes';

  @override
  String get settings_showHitboxesToggle => 'Show Hitboxes';
}
