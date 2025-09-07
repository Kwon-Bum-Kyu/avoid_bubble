import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Avoid Bubble'**
  String get title;

  /// No description provided for @startScreen_title.
  ///
  /// In en, this message translates to:
  /// **'Avoid Bubble'**
  String get startScreen_title;

  /// No description provided for @startScreen_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Survive as long as you can!'**
  String get startScreen_subtitle;

  /// No description provided for @startScreen_bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time: {time}s'**
  String startScreen_bestTime(Object time);

  /// No description provided for @startScreen_gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played: {count}'**
  String startScreen_gamesPlayed(Object count);

  /// No description provided for @startScreen_mostCommonGrade.
  ///
  /// In en, this message translates to:
  /// **'Most Common Grade: {grade}'**
  String startScreen_mostCommonGrade(Object grade);

  /// No description provided for @startScreen_startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startScreen_startGame;

  /// No description provided for @startScreen_viewRanking.
  ///
  /// In en, this message translates to:
  /// **'View Ranking'**
  String get startScreen_viewRanking;

  /// No description provided for @start_screen_controls.
  ///
  /// In en, this message translates to:
  /// **'Controls: WASD or Arrow keys to move'**
  String get start_screen_controls;

  /// No description provided for @gameOver_title.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOver_title;

  /// No description provided for @gameOver_survivalTime.
  ///
  /// In en, this message translates to:
  /// **'Survival Time'**
  String get gameOver_survivalTime;

  /// No description provided for @gameOver_timeUnit.
  ///
  /// In en, this message translates to:
  /// **'{time}s'**
  String gameOver_timeUnit(Object time);

  /// No description provided for @gameOver_grade.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String gameOver_grade(Object grade);

  /// No description provided for @gameOver_newBestRecord.
  ///
  /// In en, this message translates to:
  /// **'New Best Record!'**
  String get gameOver_newBestRecord;

  /// No description provided for @gameOver_currentRank.
  ///
  /// In en, this message translates to:
  /// **'Current Rank: {rank}'**
  String gameOver_currentRank(Object rank);

  /// No description provided for @gameOver_challengeRanking.
  ///
  /// In en, this message translates to:
  /// **'Challenge the Ranking!'**
  String get gameOver_challengeRanking;

  /// No description provided for @gameOver_registerNicknamePrompt.
  ///
  /// In en, this message translates to:
  /// **'Register your nickname to be on the ranking.'**
  String get gameOver_registerNicknamePrompt;

  /// No description provided for @gameOver_registerNicknameButton.
  ///
  /// In en, this message translates to:
  /// **'Register Nickname'**
  String get gameOver_registerNicknameButton;

  /// No description provided for @gameOver_restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get gameOver_restart;

  /// No description provided for @gameOver_menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get gameOver_menu;

  /// No description provided for @gameOver_viewRanking.
  ///
  /// In en, this message translates to:
  /// **'View Ranking'**
  String get gameOver_viewRanking;

  /// No description provided for @nickname_title.
  ///
  /// In en, this message translates to:
  /// **'Register Nickname'**
  String get nickname_title;

  /// No description provided for @nickname_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your nickname for ranking registration.'**
  String get nickname_subtitle;

  /// No description provided for @nickname_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname (2-12 chars)'**
  String get nickname_hint;

  /// No description provided for @nickname_networkError.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred.'**
  String get nickname_networkError;

  /// No description provided for @nickname_rules.
  ///
  /// In en, this message translates to:
  /// **'• Korean, English, and numbers only\n• 2-12 characters long\n• Duplicate nicknames cannot be used'**
  String get nickname_rules;

  /// No description provided for @nickname_later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get nickname_later;

  /// No description provided for @nickname_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get nickname_register;

  /// No description provided for @ranking_title.
  ///
  /// In en, this message translates to:
  /// **'🏆 Ranking'**
  String get ranking_title;

  /// No description provided for @ranking_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ranking_all;

  /// No description provided for @ranking_myRecords.
  ///
  /// In en, this message translates to:
  /// **'My Records'**
  String get ranking_myRecords;

  /// No description provided for @ranking_loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load ranking data.'**
  String get ranking_loadFailed;

  /// No description provided for @ranking_noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet.'**
  String get ranking_noRecords;

  /// No description provided for @ranking_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get ranking_refresh;

  /// No description provided for @ranking_me.
  ///
  /// In en, this message translates to:
  /// **'ME'**
  String get ranking_me;

  /// No description provided for @ranking_survivalTime.
  ///
  /// In en, this message translates to:
  /// **'Survival Time: {time}s'**
  String ranking_survivalTime(Object time);

  /// No description provided for @ranking_registerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Register a nickname to check your records.'**
  String get ranking_registerPrompt;

  /// No description provided for @ranking_noMyRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet.\nPlay a game!'**
  String get ranking_noMyRecords;

  /// No description provided for @ranking_best.
  ///
  /// In en, this message translates to:
  /// **'BEST'**
  String get ranking_best;

  /// No description provided for @ranking_noDate.
  ///
  /// In en, this message translates to:
  /// **'No date information'**
  String get ranking_noDate;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_gameDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Game Difficulty (Dev Mode)'**
  String get settings_gameDifficulty;

  /// No description provided for @settings_bulletSpeed.
  ///
  /// In en, this message translates to:
  /// **'Bullet Speed'**
  String get settings_bulletSpeed;

  /// No description provided for @settings_playerSpeed.
  ///
  /// In en, this message translates to:
  /// **'Player Speed'**
  String get settings_playerSpeed;

  /// No description provided for @settings_invincibleMode.
  ///
  /// In en, this message translates to:
  /// **'Invincible Mode'**
  String get settings_invincibleMode;

  /// No description provided for @settings_patternTimings.
  ///
  /// In en, this message translates to:
  /// **'Pattern Timings (Dev Mode)'**
  String get settings_patternTimings;

  /// No description provided for @settings_pattern1Start.
  ///
  /// In en, this message translates to:
  /// **'Pattern 1 Start (s)'**
  String get settings_pattern1Start;

  /// No description provided for @settings_pattern2Start.
  ///
  /// In en, this message translates to:
  /// **'Pattern 2 Start (s)'**
  String get settings_pattern2Start;

  /// No description provided for @settings_pattern3Start.
  ///
  /// In en, this message translates to:
  /// **'Pattern 3 Start (s)'**
  String get settings_pattern3Start;

  /// No description provided for @settings_visualAudio.
  ///
  /// In en, this message translates to:
  /// **'Visual & Audio'**
  String get settings_visualAudio;

  /// No description provided for @settings_showHitboxes.
  ///
  /// In en, this message translates to:
  /// **'Show Hitboxes (Dev Only)'**
  String get settings_showHitboxes;

  /// No description provided for @settings_hitboxInfo.
  ///
  /// In en, this message translates to:
  /// **'• Player: Green Circle\n• All Bullets: Red Circle'**
  String get settings_hitboxInfo;

  /// No description provided for @settings_soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settings_soundEffects;

  /// No description provided for @settings_sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settings_sound;

  /// No description provided for @settings_buildInfo.
  ///
  /// In en, this message translates to:
  /// **'Build Info'**
  String get settings_buildInfo;

  /// No description provided for @settings_environment.
  ///
  /// In en, this message translates to:
  /// **'Environment: {env}'**
  String settings_environment(Object env);

  /// No description provided for @settings_devFeaturesEnabled.
  ///
  /// In en, this message translates to:
  /// **'Developer features are enabled.'**
  String get settings_devFeaturesEnabled;

  /// No description provided for @settings_productionMode.
  ///
  /// In en, this message translates to:
  /// **'Running in production mode.'**
  String get settings_productionMode;

  /// No description provided for @settings_debugMode.
  ///
  /// In en, this message translates to:
  /// **'Debug Mode: {mode}'**
  String settings_debugMode(Object mode);

  /// No description provided for @settings_resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get settings_resetToDefault;

  /// No description provided for @settings_saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get settings_saveSettings;

  /// No description provided for @settings_hideHitboxes.
  ///
  /// In en, this message translates to:
  /// **'Hide Hitboxes'**
  String get settings_hideHitboxes;

  /// No description provided for @settings_showHitboxesToggle.
  ///
  /// In en, this message translates to:
  /// **'Show Hitboxes'**
  String get settings_showHitboxesToggle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
