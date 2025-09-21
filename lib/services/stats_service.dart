import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_stats.dart';

class StatsService {
  static const String _statsKey = 'game_stats';
  static StatsService? _instance;
  SharedPreferences? _prefs;
  GameStats _currentStats = GameStats();

  // 싱글톤 패턴
  static StatsService get instance {
    _instance ??= StatsService._internal();
    return _instance!;
  }

  StatsService._internal();

  // 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadStats();
  }

  // 현재 통계 가져오기
  GameStats get currentStats => _currentStats;

  // 통계 로드
  Future<void> _loadStats() async {
    try {
      final statsJson = _prefs?.getString(_statsKey);
      if (statsJson != null) {
        final Map<String, dynamic> statsMap = json.decode(statsJson);
        _currentStats = _gameStatsFromJson(statsMap);
      } else {
        // 기존 개별 키 방식으로 로드 (호환성)
        await _loadLegacyStats();
      }
    } catch (e) {
      // 로드 실패 시 기본 통계 사용
      _currentStats = GameStats();
    }
  }

  // 기존 개별 키 방식 로드 (호환성 유지)
  Future<void> _loadLegacyStats() async {
    try {
      final prefs = _prefs!;
      final gradeCount = <String, int>{};
      final grades = ['S', 'A', 'B', 'C', 'D', 'F'];

      for (String grade in grades) {
        gradeCount[grade] = prefs.getInt('grade_$grade') ?? 0;
      }

      _currentStats = GameStats(
        bestTime: prefs.getDouble('bestTime') ?? 0.0,
        totalGamesPlayed: prefs.getInt('totalGamesPlayed') ?? 0,
        totalBulletsAvoided: prefs.getInt('totalBulletsAvoided') ?? 0,
        totalPlayTime: prefs.getDouble('totalPlayTime') ?? 0.0,
        gradeCount: gradeCount,
      );

      // 새로운 JSON 형식으로 저장
      await saveStats(_currentStats);
    } catch (e) {
      _currentStats = GameStats();
    }
  }

  // 통계 저장
  Future<void> saveStats(GameStats stats) async {
    try {
      _currentStats = stats;
      final statsJson = json.encode(_gameStatsToJson(stats));
      await _prefs?.setString(_statsKey, statsJson);
    } catch (e) {
      throw Exception('Failed to save stats: $e');
    }
  }

  // 게임 결과 기록
  Future<void> recordGame(double survivalTime, String grade, int bulletsAvoided) async {
    final updatedStats = _currentStats.copyWith();

    // 최고 기록 갱신
    if (survivalTime > updatedStats.bestTime) {
      updatedStats.bestTime = survivalTime;
    }

    // 통계 업데이트
    updatedStats.totalGamesPlayed++;
    updatedStats.totalBulletsAvoided += bulletsAvoided;
    updatedStats.totalPlayTime += survivalTime;
    updatedStats.gradeCount[grade] = (updatedStats.gradeCount[grade] ?? 0) + 1;

    await saveStats(updatedStats);
  }

  // 통계 리셋
  Future<void> resetStats() async {
    await saveStats(GameStats());
  }

  // GameStats를 JSON으로 변환
  Map<String, dynamic> _gameStatsToJson(GameStats stats) {
    return {
      'bestTime': stats.bestTime,
      'totalGamesPlayed': stats.totalGamesPlayed,
      'totalBulletsAvoided': stats.totalBulletsAvoided,
      'totalPlayTime': stats.totalPlayTime,
      'gradeCount': stats.gradeCount,
    };
  }

  // JSON에서 GameStats로 변환
  GameStats _gameStatsFromJson(Map<String, dynamic> json) {
    final gradeCountJson = json['gradeCount'] as Map<String, dynamic>?;
    Map<String, int> gradeCount = {};

    if (gradeCountJson != null) {
      gradeCountJson.forEach((key, value) {
        gradeCount[key] = value as int;
      });
    } else {
      // 기본 등급 카운트
      gradeCount = {
        'S': 0,
        'A': 0,
        'B': 0,
        'C': 0,
        'D': 0,
        'F': 0,
      };
    }

    return GameStats(
      bestTime: (json['bestTime'] as num?)?.toDouble() ?? 0.0,
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      totalBulletsAvoided: json['totalBulletsAvoided'] as int? ?? 0,
      totalPlayTime: (json['totalPlayTime'] as num?)?.toDouble() ?? 0.0,
      gradeCount: gradeCount,
    );
  }
}